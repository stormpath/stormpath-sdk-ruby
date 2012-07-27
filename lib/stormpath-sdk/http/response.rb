module Stormpath

  module Http

    class Response

      attr_reader :http_status, :headers, :body
      attr_writer :headers

      def initialize http_status, content_type, body, content_length
        @http_status = http_status
        @headers = HTTP::Message::Headers.new
        @body = body
        @headers.content_type = content_type
        @headers.body_size = content_length
      end


      def client_error?
        http_status >= 400 and http_status < 500
      end

      def server_error?
        http_status >= 500 and http_status < 600
      end

      def error?
        client_error? or server_error?
      end

    end

  end

end
