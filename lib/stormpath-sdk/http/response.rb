require "httpclient"

module Stormpath

  module Http

    class Response

      attr_reader :httpStatus, :headers, :body
      attr_writer :headers

      def initialize httpStatus, contentType, body, contentLength
        @httpStatus = httpStatus
        @headers = HTTP::Message::Headers.new
        @body = body
        @headers.content_type = contentType
        @headers.body_size = contentLength
      end


      def client_error?
        httpStatus >= 400 and httpStatus < 500
      end

      def server_error?
        httpStatus >= 500 and httpStatus < 600
      end

      def error?
        client_error? or server_error?
      end

    end

  end

end
