module Stormpath

  module Http

    class HttpClientRequestExecutor

      include Stormpath::Http
      include Stormpath::Util::Assert

      def initialize(apiKey)
        @signer = Sauthc1Signer.new
        @apiKey = apiKey
        @httpClient = HTTPClient.new

      end

      def execute_request(request)

        assert_not_nil request, "Request argument cannot be null."

        domain = request.href
        #@signer.sign_request request, @apiKey TODO: get digest authentication to work
        user = @apiKey.id
        password = @apiKey.secret
        @httpClient.set_auth(domain, user, password)

        method = @httpClient.method(request.httpMethod.downcase)

        if request.body.nil?

          response = method.call domain, request.queryString, request.httpHeaders

        else

          response = method.call domain, request.body, request.httpHeaders

        end

        Response.new response.http_header.status_code, response.http_header.body_type, response.content, response.http_header.body_size

      end

    end

  end

end

