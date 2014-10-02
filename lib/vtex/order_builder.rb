module VTEX
  class OrderBuilder
    class << self
      def parse_order(vtex_order)
        {
          :id => vtex_order['id']
        }
      end

    end
  end
end
