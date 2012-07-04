module Stormpath

  module Http

    class Request

      attr_accessor :httpMethod, :href, :queryString, :httpHeaders, :body

      def initialize(httpMethod, href, queryString, httpHeaders, body)

        @httpMethod = httpMethod
        @href = href
        @queryString = queryString
        @httpHeaders = httpHeaders
        @body = body

      end

    end

  end

end
