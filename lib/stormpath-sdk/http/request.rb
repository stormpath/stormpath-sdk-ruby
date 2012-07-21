module Stormpath

  module Http

    class Request

      attr_accessor :httpMethod, :href, :queryString, :httpHeaders, :body

      def initialize(httpMethod, href, queryString, httpHeaders, body)

        @httpMethod = httpMethod.upcase
        @href = href
        @queryString = queryString
        @httpHeaders = httpHeaders
        @body = body

        if !body.nil?
          @httpHeaders.store 'Content-Length', @body.length
        end

      end

      def resource_uri
        URI href
      end

    end

  end

end
