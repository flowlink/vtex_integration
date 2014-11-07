require 'sinatra'
require 'endpoint_base'

Dir['./lib/**/*.rb'].each &method(:require)

class VTEXEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
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
    rescue => e
      code = 500
      error_notification(e)
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
    rescue => e
      code = 500
      error_notification(e)
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
    rescue => e
      code = 500
      error_notification(e)
    end

    process_result code
  end

  post '/set_inventory' do
    begin
      client   = VTEX::ClientRest.new(@config['vtex_site_id'], @config['vtex_app_key'], @config['vtex_app_token'])
      response = client.send_inventory(@payload[:inventory])
      code     = 200
      set_summary "The inventory with product: #{@payload[:inventory][:product_id]} was sent to VTEX Storefront."
    rescue VTEXEndpointError => e
      code = 500
      set_summary "Validation error has ocurred: #{e.message}"
    rescue => e
      code = 500
      error_notification(e)
    end

    process_result code
  end

  post %r{(add_product|update_product)$} do
    begin
      client   = VTEX::ClientSoap.new(@config['vtex_site_id'], @config['vtex_password'])
      products = client.send_product(@payload[:product])
      skus     = client.send_skus(@payload[:product])
      code     = 200
      set_summary "The product #{@payload[:product][:id]} and #{skus.size} SKUs were sent to VTEX Storefront."
    rescue VTEXEndpointError => e
      code = 500
      set_summary "Validation error has ocurred: #{e.message}"
    rescue => e
      code = 500
      error_notification(e)
    end

    process_result code
  end

  post '/get_products' do
    client = VTEX::ClientSoap.new(@config['vtex_site_id'], @config['vtex_password'])
    raw_products = client.get_products
    products = VTEX::ProductTransformer.map raw_products

    if products.any?
      count = products.count
      add_value 'products', products
      result 200, "Received #{count} #{"product".pluralize count} from VTEX"
    end

    result 200
  end

  def error_notification(error)
    log_exception(error)
    set_summary "A VTEX Endpoint error has ocurred: #{error.message}"
  end
end
