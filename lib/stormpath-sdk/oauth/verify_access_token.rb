module Stormpath
  module Oauth
    class VerifyAccessToken
      attr_reader :application, :verify_locally

      def initialize(application, options = {})
        @application = application
        @verify_locally = options[:local] || false
      end

      def verify(access_token)
        if verify_locally
          LocalAccessTokenVerification.new(application, access_token).verify
        else
          RemoteAccessTokenVerification.new(application, access_token).verify
        end
      end
    end
  end
end
