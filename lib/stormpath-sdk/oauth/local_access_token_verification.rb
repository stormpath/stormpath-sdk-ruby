module Stormpath
  module Oauth
    class LocalAccessTokenVerification
      attr_reader :application, :access_token

      def initialize(application, access_token)
        @application = application
        @access_token = access_token
      end

      def verify
        validate_jwt_is_an_access_token
        validate_jwt_has_a_valid_issuer
        LocalAccessTokenVerificationResult.new(application, decoded_jwt)
      end

      private

      def decoded_jwt
        begin
          @decoded_jwt ||= JWT.decode(access_token, application.client.data_store.api_key.secret)
        rescue JWT::ExpiredSignature
          raise Stormpath::Oauth::Error, :jwt_expired
        end
      end

      def validate_jwt_is_an_access_token
        return if decoded_jwt.second['stt'] == 'access'
        raise Stormpath::Oauth::Error, :jwt_invalid_stt
      end

      def validate_jwt_has_a_valid_issuer
        return if decoded_jwt.first['iss'] == application.href
        raise Stormpath::Oauth::Error, :jwt_invalid_issuer
      end
    end

    class LocalAccessTokenVerificationResult
      attr_reader :account
      def initialize(application, decoded_jwt)
        @account = application.client.accounts.get(decoded_jwt.first['sub'])
      end
    end
  end
end
