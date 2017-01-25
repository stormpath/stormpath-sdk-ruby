module Stormpath
  module Oauth
    class StormpathGrantRequest
      def initialize(account, application, api_key, status = :authenticated)
        @account = account
        @application = application
        @api_key = api_key
        @status = status.to_s.upcase
      end

      def token
        @token ||= JWT.encode(payload, api_key.secret, 'HS256')
      end

      def grant_type
        'stormpath_token'
      end

      private

      attr_accessor :account, :application, :api_key, :status

      def payload
        {
          sub: account.href,
          iat: Time.now.to_i,
          iss: application.href,
          status: status,
          aud: api_key.id
        }
      end
    end
  end
end
