module VTEX
  class ProductTransformer
    class << self
      def map(products, client)
        products.map do |product|
          product_id = product.delete(:id)
          stock_units = client.get_skus_by_product_id product_id

          parent_sku = find_parent_sku stock_units, product_id, client
          product = product.merge parent_sku

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
            variants: map_variants(stock_units, product_id, client)
          }.merge product
        end
      end

      def find_parent_sku(stock_units, product_id, client)
        if unit = stock_units.find { |u| u[:id] == product_id }
          {
            sku: unit[:id],
            price: unit[:price],
            list_price: unit[:list_price],
            cost_price: unit[:cost_price],
            images: map_images(client, unit[:id])
          }
        else
          {}
        end
      end

      def map_variants(stock_units, product_id, client)
        stock_units.map do |stock_unit|
          stock_unit_id = stock_unit.delete(:id)
          next if stock_unit_id == product_id

          {
            sku: stock_unit_id,
            price: stock_unit.delete(:price),
            list_price: stock_unit.delete(:list_price),
            cost_price: stock_unit.delete(:cost_price),
            images: map_images(client, stock_unit_id)
          }.merge stock_unit.except(:product_id)
        end.compact
      end

      def map_images(client, stock_unit_id)
        images = client.get_image_list_by_stock_keeping_unit_id stock_unit_id

        images.map do |image|
          {
            url: image[:url],
            title: image[:description],
            dimensions: {
              height: image[:height],
              width: image[:width]
            }
          }
        end
      end
    end
  end
end
