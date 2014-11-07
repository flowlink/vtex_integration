module VTEX
  class ProductTransformer
    class << self
      def map(products)
        products.map do |product|
          {
            id: product[:id],
            name: product[:name],
            description: product[:description],
            vtex: product
          }
        end
      end
    end
  end
end
