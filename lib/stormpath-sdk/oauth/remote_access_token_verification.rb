module Stormpath
  module Oauth
    class RemoteAccessTokenVerification
      attr_reader :app_href, :data_store, :access_token

      def initialize(application, access_token)
        @app_href = application.href
        @data_store = application.client.data_store
        @access_token = access_token
      end

      def verify
        data_store.get_resource("#{app_href}/authTokens/#{access_token}", VerifyToken)
      end
    end
  end
end
