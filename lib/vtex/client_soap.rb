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
                             namespaces: namespaces)
    end

    def namespaces
      {
        "xmlns:vtex" => "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts",
        "xmlns:arr"  => "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
      }
    end

    def send_product(product)
      product = VTEX::ProductBuilder.build_product(product)
      response = client.call(:product_insert_update, message: { 'tns:productVO' => product } )
      validate_response(response)
      product
    end

    def send_skus(product)
      skus     = VTEX::ProductBuilder.build_skus(product)
      skus.each do |sku_item|
        response = client.call(:stock_keeping_unit_insert_update, message: { 'tns:stockKeepingUnitVO' => sku_item } )
        validate_response(response)
      end
      skus
    end

    private

    def validate_response(response)
      raise VTEXEndpointError, response if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
