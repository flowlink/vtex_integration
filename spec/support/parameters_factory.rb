module Factories
  def self.parameters
    {
      'vtex_site_id'   => ENV['VTEX_SITE_ID'],
      'vtex_app_key'   => 'spree-key',
      'vtex_app_token' => 'token-123',
      'vtex_password'  => ENV['VTEX_PASSWORD'],
      'vtex_poll_order_timestamp' => '2014-10-05T14:49:00-03:00'
    }
  end
end
