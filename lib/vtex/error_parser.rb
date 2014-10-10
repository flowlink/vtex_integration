module VTEX
  class ErrorParser
    def self.response_has_errors?(response)
      (response.respond_to?(:http_error?) && response.http_error?) ||
      (response.respond_to?(:code) && ([400,401,404,500].include? response.code)) ||
      (response.respond_to?(:has_key?) && response.has_key?('error'))
    end
  end
end
