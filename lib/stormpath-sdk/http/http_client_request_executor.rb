require "stormpath-sdk/util/assert"
require "stormpath-sdk/http/response"
require "httpclient"

module Stormpath

  module Http

    class HttpClientRequestExecutor

      include Stormpath::Util::Assert

      def initialize(apiKey)
        @apiKey = apiKey
        @httpClient = HTTPClient.new

      end

      def execute_request(request)

        assert_not_nil request, "Request argument cannot be null."

        domain = request.href
        user = @apiKey.id
        password = @apiKey.secret
        @httpClient.set_auth(domain, user, password)

        method = @httpClient.method(request.httpMethod)

        if request.body.nil?

          response = method.call domain

        else

          response = method.call domain, request.body, {'Content-Type' => 'application/json'}

        end

        Stormpath::Http::Response.new response.http_header.status_code, response.http_header.body_type, response.content, response.http_header.body_size

      end

    end

  end

end

