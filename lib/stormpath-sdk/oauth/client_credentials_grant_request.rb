module Stormpath
  module Oauth
    class ClientCredentialsGrantRequest
      attr_reader :api_key_id, :api_key_secret

      def initialize(api_key_id, api_key_secret)
        @api_key_id = api_key_id
        @api_key_secret = api_key_secret
      end

      def grant_type
        'client_credentials'
      end
    end
  end
end
