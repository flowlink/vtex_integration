module VTEX
  class ProductBuilder
    class << self

      # Do not change the order of fields
      #
      # Id. Must be an unique integer
      #
      # RefId. Apparently can be any string, here to map Wombat IDs
      #
      def build_product(product, client)
        {
          'vtex:AdWordsRemarketingCode' => nil,
          'vtex:BrandId'                => client.find_or_create_brand(product['brand']) || 1,
          'vtex:CategoryId'             => client.find_or_create_category(product['taxons']) || 1000000,
          'vtex:DepartmentId'           => 1000000,
          'vtex:Description'            => product['description'],
          'vtex:DescriptionShort'       => nil,
          'vtex:Id'                     => product['abacos']['codigo_produto_abacos'].to_i,
          'vtex:IsActive'               => nil,
          'vtex:IsVisible'              => true,
          'vtex:KeyWords'               => product['meta_keywords'],
          'vtex:LinkId'                 => product['permalink'],
          'vtex:ListStoreId'            => nil,
          'vtex:LomadeeCampaignCode'    => nil,
          'vtex:MetaTagDescription'     => product['meta_description'],
          'vtex:Name'                   => product['name'],
          'vtex:RefId'                  => product['id'],
          'vtex:ReleaseDate'            => product['available_on'],
          'vtex:ShowWithoutStock'       => nil,
          'vtex:SupplierId'             => nil,
          'vtex:TaxCode'                => nil,
          'vtex:Title'                  => nil
         }
      end

      # Do not change the order of fields
      #
      # Id. Must be an unique integer
      #
      # RefId. Apparently can be any string, here to map Wombat IDs or Wombat
      # product variant skus
      #
      # ProductId. Must pick the same value passed to vtex:Id when creating
      # the product
      #
      def build_skus(product)
        skus = (product['variants'] || []).map do |item|
          hash = {
            'vtex:CommercialConditionId' => nil,
            'vtex:CostPrice'             => item['cost_price'],
            'vtex:CubicWeight'           => 0.02,
            'vtex:DateUpdated'           => nil,
            'vtex:EstimatedDateArrival'  => nil,
            'vtex:Height'                => 0.02,
            'vtex:Id'                    => item['abacos']['codigo_produto_abacos'].to_i,
            'vtex:InternalNote'          => nil,
            'vtex:IsActive'              => true,
            'vtex:IsAvaiable'            => nil,
            'vtex:IsKit'                 => false,
            'vtex:Length'                => 0.02,
            'vtex:ListPrice'             => item['price'],
            'vtex:ManufacturerCode'      => nil,
            'vtex:MeasurementUnit'       => nil,
            'vtex:ModalId'               => (item.has_key?('options') && item['options']['size']=='S' ? 1 : 2),
            'vtex:ModalType'             => nil,
            'vtex:Name'                  => product['name'],
            'vtex:Price'                 => item['price'],
            'vtex:ProductId'             => product['abacos']['codigo_produto_abacos'].to_i,
            'vtex:ProductName'           => product['name'],
            'vtex:RealHeight'            => nil,
            'vtex:RealLength'            => nil,
            'vtex:RealWeightKg'          => nil,
            'vtex:RealWidth'             => nil,
            'vtex:RefId'                 => item['sku'],
            'vtex:RewardValue'           => nil,
            'vtex:StockKeepingUnitEans'  => nil,
            'vtex:UnitMultiplier'        => nil,
            'vtex:WeightKg'              => 0.02,
            'vtex:Width'                 => 0.02
          }

          if item['abacos'] && item['abacos']['codigo_barras']
            hash['vtex:StockKeepingUnitEans'] = {
              'vtex:StockKeepingUnitEanDTO' => {
                'vtex:Ean' => item['abacos']['codigo_barras']
              }
            }
          end

          hash
        end

        master_product = {
          'vtex:CommercialConditionId' => nil,
          'vtex:CostPrice'             => product['cost_price'],
          'vtex:CubicWeight'           => product['weight'],
          'vtex:DateUpdated'           => nil,
          'vtex:EstimatedDateArrival'  => nil,
          'vtex:Height'                => product['height'],
          'vtex:Id'                    => product['abacos']['codigo_produto_abacos'].to_i,
          'vtex:InternalNote'          => nil,
          'vtex:IsActive'              => true,
          'vtex:IsAvaiable'            => nil,
          'vtex:IsKit'                 => false,
          'vtex:Length'                => product['height'],
          'vtex:ListPrice'             => product['price'],
          'vtex:ManufacturerCode'      => nil,
          'vtex:MeasurementUnit'       => nil,
          'vtex:ModalId'               => 1, #TODO figure out how to calculate the correct size for this product
          'vtex:ModalType'             => nil,
          'vtex:Name'                  => product['name'],
          'vtex:Price'                 => product['price'],
          'vtex:ProductId'             => product['abacos']['codigo_produto_abacos'].to_i,
          'vtex:ProductName'           => product['name'],
          'vtex:RealHeight'            => nil,
          'vtex:RealLength'            => nil,
          'vtex:RealWeightKg'          => nil,
          'vtex:RealWidth'             => nil,
          'vtex:RefId'                 => product['id'],
          'vtex:RewardValue'           => nil,
          'vtex:StockKeepingUnitEans'  => nil,
          'vtex:UnitMultiplier'        => nil,
          'vtex:WeightKg'              => product['weight'],
          'vtex:Width'                 => product['width']
        }

        if product['abacos'] && product['abacos']['codigo_barras']
          master_product['vtex:StockKeepingUnitEans'] = {
            'vtex:StockKeepingUnitEanDTO' => {
              'vtex:Ean' => product['abacos']['codigo_barras']
            }
          }
        end

        skus << master_product
        skus
      end

      def clear_id(string_id)
        string_id.gsub(/[^\d]/, '')
      end
    end
  end
end
