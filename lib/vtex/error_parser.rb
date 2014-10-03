module VTEX
  class ErrorParser
    def self.response_has_errors?(response)
      response.code == 400 || response.code == 401
    end
  end
end
