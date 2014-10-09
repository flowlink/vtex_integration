module VTEX
  class ClientSoap

    attr_reader :site_id, :client

    def initialize(site_id, password)
      @site_id = site_id
      @client = Savon.client(wsdl: 'http://webservice-sandboxintegracao.vtexcommerce.com.br/service.svc?wsdl',
                             ssl_verify_mode: :none,
                             log_level: :debug,
                             pretty_print_xml: true,
                             log: true,
                             basic_auth: [site_id, password],
                             namespaces: {"xmlns:vtex" => "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts"})
    end

    def send_product(product)
      product = VTEX::ProductBuilder.build_product(product)
# puts "\n\n #{product}\n\n"
      response = client.call(:product_insert_update, message: { 'tns:productVO' => product } )

      puts "\n\n send_product(products): #{response.inspect}"

      validate_response(response)

      products
    end

    def send_skus(product)
      skus     = VTEX::ProductBuilder.build_skus(product)

      response = client.call(:stock_keeping_unit_insert_update, message: skus )
# puts "\n\n send_product(skus): #{response.inspect}"
      validate_response(response)

      skus
    end

    private

    def validate_response(response)
      raise VTEXEndpointError, response if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
