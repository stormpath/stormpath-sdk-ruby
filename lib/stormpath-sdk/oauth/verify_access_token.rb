module Stormpath
  module Oauth
    class VerifyAccessToken
      attr_reader :application, :local

      def initialize(application, options = {})
        @application = application
        @local = options[:local]
      end

      def verify(access_token)
        if local
          LocalAccessTokenVerification.new(application, access_token).verify
        else
          RemoteAccessTokenVerification.new(application, access_token).verify
        end
      end
    end
  end
end
