require 'sinatra'
require 'endpoint_base'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/numeric/time'

Dir['./lib/**/*.rb'].each &method(:require)

class VTEXEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end

  before do
    if @config.is_a? Hash
      unless @config['vtex_soap_user'].present?
        @config['vtex_soap_user'] = @config['vtex_site_id']
      end
    end
  end

  post %r{(add_shipment|update_shipment)$} do
    begin
      client   = VTEX::ClientRest.new(@config['vtex_site_id'], @config['vtex_app_key'], @config['vtex_app_token'])
      response = client.send_shipment(@payload[:order])
      code     = 200
      set_summary "The order #{@payload[:order][:id]} was sent to VTEX Storefront."
    rescue VTEXEndpointError => e
      code = 500
      set_summary "Validation error has ocurred: #{e.message}"
    end

    process_result code
  end

  post '/get_orders' do
    begin
      client = VTEX::ClientRest.new(@config['vtex_site_id'], @config['vtex_app_key'], @config['vtex_app_token'])
      orders = client.get_orders(@config['vtex_poll_order_timestamp'])

      orders.each do |order|
        add_object "order", order
      end

      code = 200
      set_summary "#{orders.size} orders were retrieved from VTEX Storefront." if orders.any?
    rescue VTEXEndpointError => e
      code = 500
      set_summary "Validation error has ocurred: #{e.message}"
    end

    process_result code
  end

  post '/update_order_status' do
    begin
      client   = VTEX::ClientRest.new(@config['vtex_site_id'], @config['vtex_app_key'], @config['vtex_app_token'])
      response = client.send_order(@payload[:order])
      code     = 200
      set_summary "The order #{@payload[:order][:id]} was sent to VTEX Storefront."
    rescue VTEXEndpointError => e
      code = 500
      set_summary "Validation error has ocurred: #{e.message}"
    end

    process_result code
  end

  post '/set_inventory' do
    begin
      client   = VTEX::ClientRest.new(@config['vtex_site_id'], @config['vtex_app_key'], @config['vtex_app_token'])
      response = client.send_inventory(@payload[:inventory], @config['vtex_password'])
      result 200, "Sku #{@payload[:inventory][:id]} updated with quantity #{@payload[:inventory][:quantity]} in VTEX"
    rescue VTEXEndpointError => e
      result 500, e.message
    end
  end

  post %r{(add_product|update_product)$} do
    begin
      client = VTEX::ClientSoap.new(@config['vtex_soap_user'], @config['vtex_password'], @config)
      products, skus = client.send_product(@payload[:product])

      result 200, "Product #{@payload[:product][:id]} and #{skus.size} SKUs sent to VTEX"
    rescue VTEXEndpointError => e
      result 500, "Validation error has ocurred: #{e.message}"
    end
  end

  post '/get_products' do
    client = VTEX::ClientSoap.new(@config['vtex_soap_user'], @config['vtex_password'], @config)
    raw_products = client.get_products
    products = VTEX::ProductTransformer.map raw_products, client

    if (count = products.count) > 0
      add_value 'products', products
      add_parameter 'vtex_products_since', (Time.now.utc - 2.hours).iso8601

      result 200, "Received #{count} #{"product".pluralize count} from VTEX"
    end

    result 200
  end

  post '/get_skus_by_product_id' do
    client = VTEX::ClientSoap.new(@config['vtex_soap_user'], @config['vtex_password'], @config)
    stock_units = client.get_skus_by_product_id @payload[:product][:vtex_id]

    product = VTEX::ProductTransformer.product_from_skus stock_units, @payload[:product], client
    add_object "product", product

    result 200, "Updated product skus, images and specifications"
  end
end
