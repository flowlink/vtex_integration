module VTEX
  class ClientRest
    include ::HTTParty

    attr_reader :site_id, :headers, :app_key, :app_token, :config

    def initialize(config = {})
      @config = config

      @site_id = config[:vtex_site_id]
      @app_key = config[:vtex_app_key]
      @app_token = config[:vtex_app_token]

      @headers = {
                   "Content-Type"        => "application/json",
                   "Accept"              => "application/json",
                   "x-vtex-api-appKey"   => app_key,
                   "x-vtex-api-appToken" => app_token
                 }

      self.class.base_uri "http://oms.vtexcommerce.com.br/"
    end

    def get_orders(poll_order_timestamp)
      options = {
        headers: headers,
        query: { "an" => site_id, "orderBy" => "creationDate,desc"  }
      }

      response = self.class.get('/api/oms/pvt/orders', options)
      # puts "\n\n get_orders: #{response.inspect}"
      validate_response(response)

      (response['list'] || []).
        select{|order| Time.parse(order['creationDate']) >= Time.parse(poll_order_timestamp)}.
        map{|order| VTEX::OrderBuilder.parse_order(find_order(order))}
    end

    def find_order(vtex_order)
      options = {
        headers: headers,
        query: { "an" => site_id }
      }

      response = self.class.get("/api/oms/pvt/orders/#{vtex_order['orderId']}/", options)
      # puts "\n\n find_order: #{response.inspect}"
      validate_response(response, "Processing order:[#{vtex_order['orderId']}] ")

      response
    end

    def send_inventory(inventory, soap_password)
      options = {
        headers: headers
      }

      inventories= []

      vtex_sku = ClientSoap.new(config).get_sku_by_ref_id inventory['id']
      raise VTEXEndpointError, "Sku #{inventory['id']} not found in VTEX" unless vtex_sku[:id]

      inventory['id'] = vtex_sku[:id]
      inventories << VTEX::InventoryBuilder.build_inventory(inventory)
      options[:body] = inventories.to_json

      self.class.base_uri "http://#{site_id}.vtexcommercestable.com.br"

      response = self.class.post('/api/logistics/pvt/inventory/warehouseitems/setbalance', options)

      # puts "\n\n send_inventory: #{response.inspect}"
      validate_response(response)

      self.class.base_uri "http://oms.vtexcommerce.com.br/"
      response
    end

    def send_order(order)
      options = {
        headers: headers,
        query: { "an" => site_id }
      }

      response = self.class.post("/api/oms/pvt/orders/#{order['id']}/#{order['status']}/", options)
      # puts "\n\n send_order: #{response.inspect}"
      validate_response(response)
      response
    end

    private

    def validate_response(response, additional_message='')
      raise VTEXEndpointError, "#{additional_message}#{response}" if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
