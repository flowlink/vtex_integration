module VTEX
  class InventoryBuilder
    class << self

      def build_inventory(inventory)
        {
          'wareHouseId' => (inventory.has_key?('location') ? (inventory['location'] || '1_1') : '1_1'),
          'itemId'      => inventory['abacos_id'],
          'quantity'    => inventory['quantity']
        }
      end
    end
  end
end
