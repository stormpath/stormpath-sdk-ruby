module Stormpath
  module Oauth
    class AccessTokenAuthenticationResult < Stormpath::Resource::Instance
      prop_reader :access_token, :refresh_token, :token_type, :expires_in, :stormpath_access_token_href

      alias href stormpath_access_token_href

      def delete
        data_store.delete(self) unless href.respond_to?(:empty) && href.empty?
      end

      def account
        client.accounts.get(account_href)
      end

      private

      def account_href
        @account_href ||= jwt_response['sub']
      end

      def jwt_response
        JWT.decode(access_token, data_store.api_key.secret).first
      rescue JWT::ExpiredSignature => error
        raise Stormpath::Oauth::Error, :jwt_expired
      end
    end
  end
end
