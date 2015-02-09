require 'spec_helper'

describe VTEXEndpoint do
  let(:params) { Factories.parameters }

  it "checks root" do
    get '/'
    expect(last_response.status).to eq(200)
  end

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
    let(:inventory) do
      {
        'id'         =>  '31024595',
        'location'   =>  '1_1',
        'product_id' =>  '31024595',
        'abacos_id' =>  '2000005',
        'quantity'   =>  99
      }
    end

    context 'success' do
      it 'imports new inventories' do
        message = {
          inventory: inventory,
          parameters: params
        }.to_json

        VCR.use_cassette('set_inventory') do
          post '/set_inventory', message, auth

          expect(json_response[:summary]).to match /updated with quantity/
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe '/add_product' do
    let(:product) { Factories.product "222555" }

    context 'product not there' do
      it 'imports new products' do
        product['permalink'] = "product-#{product['id']}"
        product['abacos'] = {
          'codigo_barras' => "master-#{product['id']}",
        }

        message = {
          product: product,
          parameters: params
        }.to_json

        VCR.use_cassette('add_product') do
          post '/add_product', message, auth

          expect(json_response[:summary]).to match /sent to VTEX/
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe '/get_products' do
    it 'brings products' do
      message = {
        parameters: params.merge(
          vtex_products_since: "2015-02-08T15:55:20Z",
          vtex_products_limit: 10
        )
      }

      VCR.use_cassette("get_products") do
        post '/get_products', message.to_json, auth

        expect(json_response[:summary]).to match /from VTEX/
        expect(last_response.status).to eq(200)

        expect(json_response[:products].count).to be >= 1
        expect(json_response[:parameters]).to have_key 'vtex_products_since'
      end
    end

    it "brings no products" do
      message = {
        parameters: params.merge(vtex_products_since: Time.now.utc.iso8601)
      }

      allow_any_instance_of(VTEX::ClientSoap).to receive(:get_products).and_return []

      post '/get_products', message.to_json, auth

      expect(json_response[:summary]).to eq nil
      expect(last_response.status).to eq(200)

      expect(json_response[:parameters]).to eq nil
    end
  end

  it 'get skus by product id' do
    message = {
      parameters: params.merge(
        vtex_skus_since: "2014-02-11T22:25:20Z",
        vtex_skus_limit: 100
      ),
      product: {
        id: "222555",
        sku: "222555",
        vtex_id: "310114803"
      }
    }

    VCR.use_cassette("get_skus_by_product_id") do
      post '/get_skus_by_product_id', message.to_json, auth

      expect(json_response[:summary]).to match /Updated product/
      expect(last_response.status).to eq(200)

      expect(json_response[:products].count).to eq 1
      expect(json_response[:products].first[:vtex]).to have_key "variants"
    end
  end

  context "hitting public api" do
    it 'get skus by product id' do
      message = {
        parameters: params,
        product: {
          id: "31024595",
          vtex_id: "31068"
        }
      }

      VCR.use_cassette("get_product_skus_by_product_id") do
        post '/get_product_skus_by_product_id', message.to_json, auth

        expect(json_response[:summary]).to match /Updated product/
        expect(last_response.status).to eq(200)

        expect(json_response[:products].count).to eq 1
        expect(json_response[:products].first[:vtex]).to have_key "variants"
      end
    end

    it "fails early if cant find product" do
      message = {
        product: {
          vtex_id: "2003224"
        }
      }

      allow_any_instance_of(VTEX::ClientPubApi).to receive(:get_product_by_id).and_return nil
      post '/get_product_skus_by_product_id', message.to_json, auth

      expect(json_response[:summary]).to match /Could not find product/
      expect(last_response.status).to eq 500
    end
  end
end
