require 'spec_helper'

describe VTEXEndpoint do
  def app
    VTEXEndpoint
  end

  def auth
    {'HTTP_X_AUGURY_TOKEN' => '6a204bd89f3c8348afd5c77c717a097a', "CONTENT_TYPE" => "application/json"}
  end

  let(:order) { Factories.order }
  let(:original) { Factories.original }
  let(:params) { Factories.parameters }

  describe '/get_inventory' do
    context 'success' do
      it 'retrive inventory' do
        message = {
          request_id: '123456',
          parameters: params
        }.to_json

        VCR.use_cassette('get_inventory') do
          post '/get_inventory', message, auth
          last_response.status.should == 200
          last_response.body.should match /inventories were retrieved/
        end
      end
    end
  end

  describe '/get_customers' do
    context 'success' do
      it 'retrive customers' do
        message = {
          request_id: '123456',
          parameters: params
        }.to_json

        VCR.use_cassette('get_customers') do
          post '/get_customers', message, auth
          last_response.status.should == 200
          last_response.body.should match /customers were retrieved/
        end
      end
    end
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
          last_response.status.should == 200
          last_response.body.should match /orders were retrieved/
        end
      end
    end
  end

  describe '/add_order' do
    let(:order_response) { double("response", :[] => nil, :code => 200) }

    context 'success' do
      it 'imports new orders' do
        message = {
          request_id: '123456',
          order: order,
          parameters: params
        }.to_json

        VTEX::Client.any_instance.stub(:register_id => register_id )
        VTEX::Client.any_instance.stub(:payment_type_id => register_id )
        VTEX::Client.any_instance.stub(:send_order => order_response )

        VCR.use_cassette('send_order') do
          post '/add_order', message, auth
          last_response.status.should == 200
          last_response.body.should match /was sent to VTEX/
        end
      end
    end
  end


end
