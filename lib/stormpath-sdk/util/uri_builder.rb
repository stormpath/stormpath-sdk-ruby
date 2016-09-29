require 'uri'
module Stormpath
  module Util
    class UriBuilder
      attr_reader :composite_url, :escaped_url, :userinfo, :uri

      def initialize(composite_url)
        @composite_url = composite_url
      end

      def escaped_url
        @escaped_url ||= composite_url.gsub(userinfo_pattern, "://#{escaped_userinfo}@api")
      end

      def userinfo
        @userinfo ||= composite_url.scan(userinfo_pattern).flatten.first
      end

      def uri
        begin
          @uri ||= URI(escaped_url)
        rescue
          raise StandardError, 'Something is wrong with the composite url'
        end
      end

      private

      def escaped_userinfo
        URI.escape(userinfo, '/')
      end

      def userinfo_pattern
        /:\/\/(.*?)@api/m
      end
    end
  end
end
