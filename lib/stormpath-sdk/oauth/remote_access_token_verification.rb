module Stormpath
  module Oauth
    class RemoteAccessTokenVerification
      attr_reader :application, :app_href, :data_store, :access_token

      def initialize(application, access_token)
        @application = application
        @app_href = application.href
        @data_store = application.client.data_store
        @access_token = access_token
        validate_access_token
      end

      def verify
        data_store.get_resource("#{app_href}/authTokens/#{access_token}", VerifyTokenResult)
      end

      def validate_access_token
        raise Stormpath::Oauth::Error, :jwt_invalid_stt unless decoded_jwt.second['stt'] == 'access'
        raise Stormpath::Oauth::Error, :jwt_invalid_issuer unless decoded_jwt.first['iss'] == application.href
      end

      def decoded_jwt
        @decoded_jwt ||= JWT.decode(access_token, application.client.data_store.api_key.secret)
      end
    end
  end
end
