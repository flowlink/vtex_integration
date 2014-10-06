require_relative './vtex/client'
require_relative './vtex/order_builder'
require_relative './vtex/inventory_builder'
require_relative './vtex/error_parser'

class VTEXEndpointError < StandardError; end
