require "httpclient"

module Stormpath

  module Http

    class HttpClientRequestExecutor

      def initialize(apiKey)
        @apiKey = apiKey
        @httpClient = HTTPClient.new

      end

      def execute_request(request)

        domain = request.href
        user = @apiKey.id
        password = @apiKey.secret
        @httpClient.set_auth(domain, user, password)

        method = @httpClient.method(request.httpMethod)

        method.call domain

      end
    end

  end

end

