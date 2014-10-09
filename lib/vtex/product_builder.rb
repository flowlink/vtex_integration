module VTEX
  class ProductBuilder
    class << self

      # {
      #   "products": [
      #     {
      #       "id": "SPREE-T-SHIRT996973",
      #       "name": "Spree T-Shirt",
      #       "sku": "SPREE-T-SHIRT",
      #       "description": "Awesome Spree T-Shirt",
      #       "price": 35,
      #       "cost_price": 22.33,
      #       "available_on": "2014-01-29T14:01:28.000Z",
      #       "permalink": "spree-tshirt",
      #       "meta_description": null,
      #       "meta_keywords": null,
      #       "shipping_category": "Default",
      #       "taxons": [
      #         [
      #           "Categories",
      #           "Clothes",
      #           "T-Shirts"
      #         ],
      #         [
      #           "Brands",
      #           "Spree"
      #         ],
      #         [
      #           "Brands",
      #           "Open Source"
      #         ]
      #       ],
      #       "options": [
      #         "color",
      #         "size"
      #       ],
      #       "properties": {
      #         "material": "cotton",
      #         "fit": "smart fit"
      #       },
      #       "images": [
      #         {
      #           "url": "http://dummyimage.com/600x400/000/fff.jpg&text=Spree T-Shirt",
      #           "position": 1,
      #           "title": "Spree T-Shirt - Grey Small",
      #           "type": "thumbnail",
      #           "dimensions": {
      #             "height": 220,
      #             "width": 100
      #           }
      #         }
      #       ],
      #       "variants": [
      #         {
      #           "sku": "SPREE-T-SHIRT-S",
      #           "price": 39.99,
      #           "cost_price": 22.33,
      #           "quantity": 1,
      #           "options": {
      #             "color": "GREY",
      #             "size": "S"
      #           },
      #           "images": [
      #             {
      #               "url": "http://dummyimage.com/600x400/000/fff.jpg&text=Spree T-Shirt Grey Small",
      #               "position": 1,
      #               "title": "Spree T-Shirt - Grey Small",
      #               "type": "thumbnail",
      #               "dimensions": {
      #                 "height": 220,
      #                 "width": 100
      #               }
      #             }
      #           ]
      #         }
      #       ]
      #     }
      #   ]
      # }

      def build_product(product)
        {
          'vtex:Id'                     => 1,
          'vtex:Name'                   => product['name'],
          'vtex:DepartmentId'           => 1000000,
          'vtex:CategoryId'             => 1000000,
          'vtex:BrandId'                => 1,
          'vtex:LinkId'                 => product['permalink'],
          'vtex:RefId'                  => product['id'],
          'vtex:IsVisible'              => true,
          'vtex:Description'            => product['description'],
          'vtex:ReleaseDate'            => product['available_on'],
          'vtex:KeyWords'               => product['meta_keywords'],
          'vtex:MetaTagDescription'     => product['meta_description'],
          'vtex:AdWordsRemarketingCode' => nil,
          'vtex:DescriptionShort'       => nil,
          'vtex:IsActive'               => nil,
          'vtex:ListStoreId'            => nil,
          'vtex:LomadeeCampaignCode'    => nil,
          'vtex:ShowWithoutStock'       => nil,
          'vtex:SupplierId'             => nil,
          'vtex:TaxCode'                => nil,
          'vtex:Title'                  => nil
         }
      end

      def build_skus(product)
        skus = (product['variants'] || []).each_with_index.map do |item, i|
          {
            'StockKeepingUnitDTO' => {
              'ProductId'   => product['id'],
              # 'Id'         => product['id'], --variants don't have Id
              'Name'        => product['name'],
              'RefId'       => product['id'],
              'CostPrice'   => item['cost_price'],
              'ListPrice'   => item['price'],
              'Price'       => item['price'],
              'Height'      => 0,
              'Length'      => 0,
              'Width'       => 0,
              'ModalId'     => (item['options']['size']=='S' ? 1 : 2),
              'IsActive'    => true,
              'ProductName' => product['name']
            }
          }
        end

        skus << { #Product SKU
            'StockKeepingUnitDTO' => {
              'ProductId'   => product['id'],
              'Id'          => product['id'],
              'Name'        => product['name'],
              'RefId'       => product['id'],
              'CostPrice'   => product['cost_price'],
              'ListPrice'   => product['price'],
              'Price'       => product['price'],
              'Height'      => 0,
              'Length'      => 0,
              'Width'       => 0,
              'ModalId'     => 1, #TODO figure out how to calculate the correct size for this product
              'IsActive'    => true,
              'ProductName' => product['name']
            }
          }
      end
    end
  end
end
