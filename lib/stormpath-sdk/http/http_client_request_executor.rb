require "httpclient"
require "base64"

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

        if request.body.nil?

          method.call domain

        else

          method.call domain, request.body, {'Authorization' => ' Basic ' + Base64.encode64(user + ':' + password), 'Content-Type' => 'application/json'}

        end

      end

    end

  end

end

