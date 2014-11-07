module VTEX
  class ProductTransformer
    class << self
      def map(products, client)
        products.map do |product|
          product_id = product.delete(:id)
          {
            id: product_id,
            channel: 'vtex',
            name: product.delete(:name),
            description: product.delete(:description),
            permalink: product.delete(:link_id),
            available_on: product.delete(:release_date),
            meta_keywords: product.delete(:key_words),
            meta_description: product.delete(:title),
            is_visible: product.delete(:is_visible),
            is_active: product.delete(:is_active),
            variants: map_variants(client.get_skus_by_product_id product_id)
          }.merge product
        end
      end

      def map_variants(stock_units)
        stock_units.map do |stock_unit|
          {
            sku: stock_unit.delete(:id),
            price: stock_unit.delete(:price),
            list_price: stock_unit.delete(:list_price),
            cost_price: stock_unit.delete(:cost_price)
          }.merge stock_unit
        end
      end
    end
  end
end
