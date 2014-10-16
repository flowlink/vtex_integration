require 'spec_helper'

describe VTEXEndpoint do
  def app
    VTEXEndpoint
  end

  def auth
    {'HTTP_X_AUGURY_TOKEN' => '6a204bd89f3c8348afd5c77c717a097a', "CONTENT_TYPE" => "application/json"}
  end

  let(:inventory) { Factories.inventory }
  let(:product) { Factories.product }
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
          expect(last_response.status).to eq(200)
          expect(last_response.body).to match /orders were retrieved/
        end
      end
    end
  end

  describe '/set_inventory' do

    context 'success' do
      it 'imports new inventories' do
        message = {
          request_id: '123456',
          inventory: inventory,
          parameters: params
        }.to_json

        VCR.use_cassette('set_inventory') do
          post '/set_inventory', message, auth

          expect(last_response.status).to eq(200)
          expect(last_response.body).to match /was sent to VTEX Storefront/
        end
      end
    end
  end

  describe '/add_product' do

    context 'success' do
      it 'imports new products' do
        message = {
          request_id: '123456',
          product: product,
          parameters: params
        }.to_json

        VCR.use_cassette('add_product') do
          post '/add_product', message, auth

          expect(last_response.status).to eq(200)
          expect(last_response.body).to match /were sent to VTEX Storefront/
        end
      end
    end
  end


end
