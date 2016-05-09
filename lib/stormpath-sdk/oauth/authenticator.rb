module Stormpath
  module Oauth
    class Authenticator
      include Stormpath::Util::Assert

      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, request
        assert_not_nil parent_href, "parent_href must be specified"

        if request.grant_type == 'password'
          attempt = @data_store.instantiate PasswordGrant
        elsif request.grant_type == 'refresh_token'
          attempt = @data_store.instantiate RefreshToken
        elsif request.grant_type == 'id_site_token'
          attempt = @data_store.instantiate IdSiteGrant
        end

        attempt.set_options(request)

        href = parent_href + '/oauth/token'
        @data_store.create href, attempt, Stormpath::Authentication::JwtAuthenticationResult
      end
    end
  end
end
