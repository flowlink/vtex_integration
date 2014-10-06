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
        break if Time.parse(order['creationDate']) < Time.parse(poll_order_timestamp)

        orders << VTEX::OrderBuilder.parse_order(find_order(order))
      end
      orders
    end

    def find_order(vtex_order)
      options = {
        headers: headers,
        query: { "an" => site_id }
      }

      response = self.class.get("/api/oms/pvt/orders/#{vtex_order['orderId']}/", options)
      # puts "\n\n find_order: #{response.inspect}"
      validate_response(response)

      response
    end

    private

    def validate_response(response)
      raise VTEXEndpointError, response if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
