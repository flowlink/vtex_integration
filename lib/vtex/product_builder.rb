module VTEX
  class ProductBuilder
    class << self

      # Do not change the order of fields
      def build_product(product)
        {
          'vtex:AdWordsRemarketingCode' => nil,
          'vtex:BrandId'                => 1,
          'vtex:CategoryId'             => 1000000,
          'vtex:DepartmentId'           => 1000000,
          'vtex:Description'            => product['description'],
          'vtex:DescriptionShort'       => nil,
          'vtex:Id'                     => clear_id(product['id']),
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

      #Do not change the order of fields
      def build_skus(product)
        skus = (product['variants'] || []).each_with_index.map do |item, i|
          {
            'vtex:CommercialConditionId' => nil,
            'vtex:CostPrice'             => item['cost_price'],
            'vtex:CubicWeight'           => 0,
            'vtex:DateUpdated'           => nil,
            'vtex:EstimatedDateArrival'  => nil,
            'vtex:Height'                => 0,
            'vtex:Id'                    => (item.has_key?('id') ? clear_id(item['id']) : nil),
            'vtex:InternalNote'          => nil,
            'vtex:IsActive'              => true,
            'vtex:IsAvaiable'            => nil,
            'vtex:IsKit'                 => false,
            'vtex:Length'                => 0,
            'vtex:ListPrice'             => item['price'],
            'vtex:ManufacturerCode'      => nil,
            'vtex:MeasurementUnit'       => nil,
            'vtex:ModalId'               => (item['options']['size']=='S' ? 1 : 2),
            'vtex:ModalType'             => nil,
            'vtex:Name'                  => product['name'],
            'vtex:Price'                 => item['price'],
            'vtex:ProductId'             => clear_id(product['id']),
            'vtex:ProductName'           => product['name'],
            'vtex:RealHeight'            => nil,
            'vtex:RealLength'            => nil,
            'vtex:RealWeightKg'          => nil,
            'vtex:RealWidth'             => nil,
            'vtex:RefId'                 => clear_id(product['id']),
            'vtex:RewardValue'           => nil,
            'vtex:StockKeepingUnitEans'  => nil,
            'vtex:UnitMultiplier'        => nil,
            'vtex:WeightKg'              => 0,
            'vtex:Width'                 => 0
          }
        end

        skus << {
                'vtex:CommercialConditionId' => nil,
                'vtex:CostPrice'             => product['cost_price'],
                'vtex:CubicWeight'           => 0,
                'vtex:DateUpdated'           => nil,
                'vtex:EstimatedDateArrival'  => nil,
                'vtex:Height'                => 0,
                'vtex:Id'                    => (product.has_key?('id') ? clear_id(product['id']) : nil),
                'vtex:InternalNote'          => nil,
                'vtex:IsActive'              => true,
                'vtex:IsAvaiable'            => nil,
                'vtex:IsKit'                 => false,
                'vtex:Length'                => 0,
                'vtex:ListPrice'             => product['price'],
                'vtex:ManufacturerCode'      => nil,
                'vtex:MeasurementUnit'       => nil,
                'vtex:ModalId'               => 1, #TODO figure out how to calculate the correct size for this product
                'vtex:ModalType'             => nil,
                'vtex:Name'                  => product['name'],
                'vtex:Price'                 => product['price'],
                'vtex:ProductId'             => clear_id(product['id']),
                'vtex:ProductName'           => product['name'],
                'vtex:RealHeight'            => nil,
                'vtex:RealLength'            => nil,
                'vtex:RealWeightKg'          => nil,
                'vtex:RealWidth'             => nil,
                'vtex:RefId'                 => clear_id(product['id']),
                'vtex:RewardValue'           => nil,
                'vtex:StockKeepingUnitEans'  => nil,
                'vtex:UnitMultiplier'        => nil,
                'vtex:WeightKg'              => 0,
                'vtex:Width'                 => 0
              }
        skus
      end

      def clear_id(string_id)
        string_id.gsub(/[^\d]/, '')
      end
    end
  end
end
