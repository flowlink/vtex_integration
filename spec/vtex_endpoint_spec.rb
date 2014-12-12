require 'spec_helper'

describe VTEXEndpoint do
  let(:params) { Factories.parameters }

  describe '/get_orders' do
    context 'success' do
      it 'retrive orders' do
        message = {
          request_id: '123456',
          parameters: params
        }.to_json

        VCR.use_cassette('get_orders') do
          post '/get_orders', message, auth
          expect(json_response[:summary]).to match /orders were retrieved/
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe '/set_inventory' do
    let(:inventory) { Factories.inventory }

    context 'success' do
      it 'imports new inventories' do
        message = {
          inventory: inventory,
          parameters: params
        }.to_json

        VCR.use_cassette('set_inventory') do
          post '/set_inventory', message, auth

          expect(json_response[:summary]).to match /was sent to VTEX Storefront/
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe '/add_product' do
    let(:product) { Factories.product "888888" }

    context 'success' do
      it 'imports new products' do
        product['permalink'] = "product-#{product['id']}"
        product['abacos'] = {
          'codigo_barras' => "master-#{product['id']}",
          'codigo_produto_abacos' => "1#{product['id']}"
        }

        message = {
          product: product,
          parameters: params
        }.to_json

        VCR.use_cassette('add_product') do
          post '/add_product', message, auth

          expect(json_response[:summary]).to match /were sent to VTEX Storefront/
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe '/get_products' do
    it 'brings products' do
      message = {
        parameters: params.merge(vtex_products_since: "2014-12-11T22:25:20Z")
      }

      VCR.use_cassette("1415400936") do
        post '/get_products', message.to_json, auth

        expect(json_response[:summary]).to match /from VTEX/
        expect(last_response.status).to eq(200)

        expect(json_response[:products].count).to be >= 1
        expect(json_response[:parameters]).to have_key 'vtex_products_since'

        json_response[:products].each do |p|
          p[:variants].each do |variant|
            expect(variant[:sku]).not_to eq p[:sku]
          end
        end
      end
    end

    it "brings no products" do
      message = {
        parameters: params.merge(vtex_products_since: Time.now.utc.iso8601)
      }

      VCR.use_cassette("no_products_1415323854") do
        post '/get_products', message.to_json, auth

        expect(json_response[:summary]).to eq nil
        expect(last_response.status).to eq(200)

        expect(json_response[:parameters]).to eq nil
      end
    end
  end
end
