module Stormpath
  module Oauth
    class LocalAccessTokenVerification
      attr_reader :application, :access_token

      def initialize(application, access_token)
        @application = application
        @access_token = access_token
        validate_jwt
      end

      def jwt
        begin
          @jwt ||= LocalAccessTokenVerificationResult.new(application, decoded_jwt)
        rescue JWT::ExpiredSignature
          raise Stormpath::Oauth::Error, :jwt_expired
        end
      end
      alias_method :verify, :jwt

      private

      def decoded_jwt
        JWT.decode(access_token, application.client.data_store.api_key.secret)
      end

      def validate_jwt
        validate_jwt_is_an_access_token
        validate_jwt_has_a_valid_issuer
      end

      def validate_jwt_is_an_access_token
        return if jwt.token_type == 'access'
        raise ArgumentError, 'Token is not an access token'
      end

      def validate_jwt_has_a_valid_issuer
        return if jwt.application_href == application.href
        raise ArgumentError, 'Token issuer is invalid'
      end
    end

    class LocalAccessTokenVerificationResult
      attr_reader :jwt, :account
      def initialize(application, jwt)
        @jwt = jwt
        @account = application.client.accounts.get(jwt.first['sub'])
      end

      def application_href
        jwt.first['iss']
      end

      def token_type
        jwt.second['stt']
      end
    end
  end
end
