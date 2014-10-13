module VTEX
  class InventoryBuilder
    class << self

      def build_inventory(inventory)
        {
          'wareHouseId' => (inventory.has_key?('location') ? (inventory['location'] || '1_1') : '1_1'),
          'itemId'      => inventory['product_id'],
          'quantity'    => inventory['quantity']
        }
      end
    end
  end
end
