module VTEX
  class InventoryBuilder
    class << self

      def build_inventory(inventory)
        {
          'wareHouseId' => inventory['location'] || '1_1',
          'itemId'      => inventory['abacos_id'],
          'quantity'    => inventory['quantity'].to_i
        }
      end
    end
  end
end
