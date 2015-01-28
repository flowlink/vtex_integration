require_relative 'vtex/client_rest'
require_relative 'vtex/client_soap'
require_relative 'vtex/client_pub_api'
require_relative 'vtex/order_builder'
require_relative 'vtex/inventory_builder'
require_relative 'vtex/product_builder'
require_relative 'vtex/error_parser'

class VTEXEndpointError < StandardError; end
