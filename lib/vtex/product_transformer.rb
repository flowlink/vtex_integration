module VTEX
  class ProductTransformer
    class << self
      def map(products, client)
        products.map do |product|
          product_id = product.delete(:id)
          ref_id = product.delete(:ref_id)

          next unless ref_id

          {
            id: ref_id,
            vtex_id: product_id,
            updated_at: Time.now.utc.iso8601,
            vtex: {
              sku: ref_id,
              name: product.delete(:name),
              description: product.delete(:description),
              permalink: product.delete(:link_id),
              available_on: product.delete(:release_date),
              meta_keywords: product.delete(:key_words),
              meta_description: product.delete(:title),
              is_visible: product.delete(:is_visible),
              is_active: product.delete(:is_active)
            }.merge(product)
          }
        end.compact
      end

      def product_from_pub_api(json, wombat_product, client, soap_client)
        json[:name] = json.delete('productName')
        json[:brand] = json.delete('brand')
        json[:description] = json.delete('description')
        json[:permalink] = json.delete('linkText')
        json[:link] = json.delete('link')
        json.delete('productReference')
        json[:categories] = json.delete('categories')
        json[:categories].reverse!
        json[:categories].map! do |c|
          c.gsub!(/\A\/|\/\Z/,"")
          c.split("/").last
        end
        json[:variants] = []
        json['items'].each do |variant|
          variant[:sku] = variant['referenceId'].first['Value']
          variant.delete('referenceId')
          variant[:vtex_id] = wombat_product[:vtex_id]
          variant[:vtex_sku_id] = variant.delete('itemId')
          variant[:name] = variant.delete('name')
          variant[:full_name] = variant.delete('nameComplete')
          variant[:complement_name] = variant.delete('complementName')
          variant[:barcode] = variant.delete('ean')
          variant[:images] = variant.delete('images').to_a.map do |img|
            {
              url: img['imageUrl'],
              title: img['imageText']
            }
          end
          seller = variant.delete('sellers').first
          variant[:price] = seller['commertialOffer']['Price']
          variant[:list_price] = seller['commertialOffer']['ListPrice']
          variant[:hand_on_count] = seller['commertialOffer']['AvailableQuantity']
          variant[:vtex_options] = {}
          if variant.has_key?('variations')
            variant['variations'].each do |option|
              variant[:vtex_options][option.delete(':').parameterize.underscore.to_sym] = variant.delete(option).join
            end
            variant.delete('variations')
          end
          json[:variants] << variant
        end
        json.delete('items')

        json[:specifications] = []
        json['allSpecifications'].each do |spec|
          json[:specifications] << {
            name: spec.delete(':'),
            value: json.delete(spec).join
          }
        end
        json.delete('Especificações:')
        json.delete('allSpecifications')

        json[:variants].map! do |variant|
          if new_info = soap_client.get_sku_by_ref_id(variant[:sku])
            variant.merge(new_info)
          else
            variant
          end
        end

        parent_sku = json[:variants].select { |sku| sku[:sku] == wombat_product[:id] }.first
        json[:variants].reject! { |sku| sku[:sku] == wombat_product[:id] }

        wombat_product = {
          id: wombat_product[:id],
          vtex_id: wombat_product[:vtex_id],
          vtex: {
            updated_at: Time.now.utc.iso8601,
          }.merge(json)
        }.merge(parent_sku.slice(:sku, :vtex_sku_id, :price, :list_price, :cost_price, :images, :height, :width, :length, :weight_kg, :is_active))
      end

      def product_from_skus(stock_units, wombat_product, client)
        product_id = wombat_product[:vtex_id]
        ref_id = wombat_product[:sku]

        stock_units.map! do |unit|
          if new_info = client.get_sku_by_ref_id(unit[:ref_id])
            unit.merge(new_info)
          else
            unit
          end
        end

        parent_sku = find_parent_sku stock_units, ref_id, client
        variants = map_variants stock_units, ref_id, client

        wombat_product = {
          id: wombat_product[:id],
          vtex: {
            updated_at: Time.now.utc.iso8601,
            variants: variants,
            specifications: map_specifications(client, product_id)
          }
        }.merge parent_sku
      end

      def find_parent_sku(stock_units, ref_id, client)
        if unit = stock_units.find { |u| u[:ref_id] == ref_id }
          {
            sku: unit[:ref_id],
            vtex_sku_id: unit[:id],
            price: unit[:price],
            list_price: unit[:list_price],
            cost_price: unit[:cost_price],
            images: map_images(client, unit[:id])
          }
        else
          {}
        end
      end

      def map_variants(stock_units, ref_id, client)
        stock_units.map do |stock_unit|
          stock_unit_id = stock_unit.delete(:id)
          variant_ref_id = stock_unit[:ref_id]

          next if variant_ref_id == ref_id

          {
            sku: variant_ref_id,
            vtex_id: stock_unit.delete(:product_id),
            vtex_sku_id: stock_unit_id,
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

      def map_specifications(client, product_id)
        specifications = client.get_product_specifications_by_product_id product_id

        specifications.map do |spec|
          {
            name: spec[:name].delete(':'),
            value: spec[:description]
          }
        end
      end
    end
  end
end
