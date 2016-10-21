module Stormpath
  module Authentication
    class HttpBearerAuthentication
      BEARER_PATTERN = /^Bearer /
      attr_reader :application, :authorization_header, :local

      def initialize(application, authorization_header, options = {})
        @application = application
        @authorization_header = authorization_header
        @local = options[:local]
        raise Stormpath::Error if authorization_header.nil?
      end

      def authenticate!
        if local
          Stormpath::Oauth::LocalAccessTokenVerification.new(application, bearer_access_token).verify
        else
          Stormpath::Oauth::RemoteAccessTokenVerification.new(application, bearer_access_token).verify
        end
      end

      private

      def bearer_access_token
        raise Stormpath::Error unless authorization_header =~ BEARER_PATTERN
        authorization_header.gsub(BEARER_PATTERN, '')
      end
    end
  end
end
