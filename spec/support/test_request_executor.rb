module Stormpath
  module Test
    class TestRequestExecutor
      attr_writer :response

      def execute_request(request, api_key)
        Stormpath::Http::Response.new 200, 'text/json', @response, @response.length
      end
    end
  end
end
