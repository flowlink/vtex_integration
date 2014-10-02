module VTEX
  class Client
    include ::HTTParty

    attr_reader :site_id, :headers, :app_key, :app_token

    def initialize(site_id, app_key, app_token)
      @site_id = site_id
      @headers = { "Content-Type" => "application/json",
                   "Accept" => "application/json",
                   "x-vtex-api-appKey" => app_key,
                   "x-vtex-api-appToken"=> app_token
                 }


      self.class.base_uri "http://oms.vtexcommerce.com.br/"
    end

    def get_orders(poll_order_timestamp)
      options = {
        headers: headers,
        query: { "an" => site_id, "orderBy" => "creationDate,desc"  }
      }

      response = self.class.get('/api/oms/pvt/orders', options)
      puts "\n\n get_orders: #{response.inspect}"
      validate_response(response)

      orders = []
      (response['list'] || []).each_with_index.map do |order, i|
        orders << VTEX::OrderBuilder.parse_order(find_order(order))
      end
      orders
    end

    def find_order(vtex_order)
      options = {
        headers: headers,
        query: { "an" => site_id }
      }

      response = self.class.get("/api/oms/pvt/orders/#{vtex_order['id']}/", options)
      puts "\n\n find_order: #{response.inspect}"
      validate_response(response)

      response['list'][0]
    end

    def send_order(payload)
      # order_placed_hash   = VTEX::OrderBuilder.order_placed(self, payload)

      options = {
        headers: headers,
        basic_auth: auth,
        body: order_placed_hash.to_json
      }

      response = self.class.post('/register_sales', options)
      validate_response(response)
    end


    private

    def validate_response(response)
      raise VTEXEndpointError, response if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
