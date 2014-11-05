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

    def get_products
      response = client.call(
        :product_get_all_from_updated_date_and_id,
        message: {
          'tns:dateUpdated' => "2014-10-05T21:25:20Z",
          'tns:topRows' => 10,
        }
      )
    end

    def send_product(product)
      product = VTEX::ProductBuilder.build_product(product, self)
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

    def find_or_create_brand(brand_name)
      response = client.call(:brand_get_by_name, message: { 'tns:nameBrand' => brand_name } )
      validate_response(response)

      response.body[:brand_get_by_name_response][:brand_get_by_name_result][:id] ||
        create_brand(brand_name)
    end

    def find_or_create_category(taxons)
      return if taxons.to_a.empty?

      category_name = taxons.first.last

      find_category(category_name) || create_category_base_on_taxons(taxons)
    end

    private

    def find_category(category_name)
      response = client.call(:category_get_by_name, message: { 'tns:nameCategory' => category_name } )
      validate_response(response)
      response.body[:category_get_by_name_response][:category_get_by_name_result][:id]
    end

    def send_category(category_name, father_id)
      response = client.call(:category_insert_update, message: { 'tns:category' => {  'vtex:FatherCategoryId' => father_id,
                                                                                      'vtex:IsActive'         => true,
                                                                                      'vtex:Name'             => category_name
                                                                                    } } )
      validate_response(response)

      response.body[:category_insert_update_response][:category_insert_update_result][:id]
    end

    def create_category_base_on_taxons(taxons)
      categories = taxons.first
      father_id  = find_category(categories.first) || send_category(categories.first, nil)
      send_category(categories.last, father_id)
    end

    def create_brand(brand_name)
      response = client.call(:brand_insert_update, message: { 'tns:brand' => { 'vtex:IsActive'               => true,
                                                                               'vtex:AdWordsRemarketingCode' => nil,
                                                                               'vtex:Name'                   => brand_name,
                                                                               'vtex:Title'                  => brand_name
                                                                               } } )
      validate_response(response)

      response.body[:brand_insert_update_response][:brand_insert_update_result][:id]
    end

    def validate_response(response)
      raise VTEXEndpointError, response if VTEX::ErrorParser.response_has_errors?(response)
      response
    end

  end
end
