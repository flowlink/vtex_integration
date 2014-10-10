module VTEX
  class ErrorParser
    def self.response_has_errors?(response)
      (response.respond_to?(:http_error?) && response.http_error?) ||
      (response.respond_to?(:code) && (response.code == 400 ||
                                       response.code == 401 ||
                                       response.code == 404 ||
                                       response.code == 500)) ||
      (response.respond_to?(:has_key?) && response.has_key?('error'))
    end
  end
end
