module VTEX
  class ClientPubApi
    include ::HTTParty

    attr_reader :site_id, :headers, :config

    def initialize(config = {})
      @config = config

      @headers = {
         "Content-Type"        => "application/json",
         "Accept"              => "application/json"
       }

       self.class.base_uri @config['vtex_pub_api_url']
    end

    def get_product_by_id(product_id)
      options = {
        headers: headers
      }
      response = self.class.get("/api/catalog_system/pub/products/search/?fq=productId:#{product_id}", options)

      response.first
    end
  end
end