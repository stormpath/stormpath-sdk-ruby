module Stormpath
  module Authentication
    class HttpBasicAuthentication
      BASIC_PATTERN = /^Basic /
      attr_reader :application, :authorization_header

      def initialize(application, authorization_header)
        @application = application
        @authorization_header = authorization_header
        raise Stormpath::Error if authorization_header.nil?
      end

      def authenticate!
        raise Stormpath::Error if fetched_api_key.nil?
        raise Stormpath::Error if fetched_api_key.secret != api_key_secret
        fetched_api_key.account
      end

      private

      def fetched_api_key
        @fetched_api_key ||= application.api_keys.search(id: api_key_id).first
      end

      def api_key_id
        decoded_authorization_header.first
      end

      def api_key_secret
        decoded_authorization_header.last
      end

      def decoded_authorization_header
        @decoded_authorization_header ||= begin
          api_key_and_secret = Base64.decode64(basic_authorization_header).split(':')
          raise Stormpath::Error if api_key_and_secret.count != 2
          api_key_and_secret
        end
      end

      def basic_authorization_header
        raise Stormpath::Error unless authorization_header =~ BASIC_PATTERN
        authorization_header.gsub(BASIC_PATTERN, '')
      end
    end
  end
end
