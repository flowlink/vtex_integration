module VTEX
  class InventoryBuilder
    class << self

      # {
      #   "inventory": [
      #     {
      #       "id": "12876920",
      #       "location": "us_warehouse",
      #       "product_id": "SPREE-T-SHIRT",
      #       "quantity": 93
      #     }
      #   ]
      # }
      def build_inventory(inventory)
        {
          'wareHouseId' => (inventory.has_key?('location') ? inventory['location'] : ''),
          'itemId'      => inventory['product_id'],
          'quantity'    => inventory['quantity']
        }
      # [\n  {\n  "wareHouseId":"1_1",\n  "itemId":"1",\n  "quantity":1  \n  }\n ]
      end
    end
  end
end
