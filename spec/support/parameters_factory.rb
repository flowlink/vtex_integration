module Factories
  def self.parameters
    {
      'vtex_site_id'   => ENV['VTEX_SITE_ID'],
      'vtex_soap_user' => ENV['VTEX_SOAP_USER'],
      'vtex_app_key'   => ENV['VTEX_APP_KEY'],
      'vtex_app_token' => ENV['VTEX_APP_TOKEN'],
      'vtex_password'  => ENV['VTEX_PASSWORD'],
      'vtex_soap_url'  => ENV['VTEX_SOAP_URL'],
      'vtex_poll_order_timestamp' => '2014-10-05T14:49:00-03:00'
    }
  end
end
