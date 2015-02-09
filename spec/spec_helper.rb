require 'rubygems'
require 'bundler'
require 'sinatra'
require 'dotenv'
Dotenv.load

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'vtex_endpoint.rb')

Dir['./spec/support/**/*.rb'].each &method(:require)

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['VTEX_SITE_ID'] ||= 'siteid'
ENV['VTEX_PASSWORD'] ||= 'passwd'
ENV['VTEX_APP_KEY'] ||= 'appkey'
ENV['VTEX_APP_TOKEN'] ||= 'apptoken'
ENV['VTEX_SOAP_USER'] ||= 'soapuser'
ENV['VTEX_SOAP_URL'] ||= 'soapurl.com'
ENV['VTEX_PUB_API_URL'] ||= 'test.com'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock

  # c.force_utf8_encoding = true

  c.filter_sensitive_data("VTEX_SITE_ID") { ENV["VTEX_SITE_ID"] }
  c.filter_sensitive_data("VTEX_SOAP_USER") { ENV["VTEX_SOAP_USER"] }
  c.filter_sensitive_data("VTEX_SOAP_URL") { ENV["VTEX_SOAP_URL"] }
  c.filter_sensitive_data("VTEX_PASSWORD") { ENV["VTEX_PASSWORD"] }
  c.filter_sensitive_data("VTEX_APP_KEY") { ENV["VTEX_APP_KEY"] }
  c.filter_sensitive_data("VTEX_APP_TOKEN") { ENV["VTEX_APP_TOKEN"] }
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers

  config.order = 'random'
end
