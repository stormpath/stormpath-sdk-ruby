module Stormpath
  module Oauth
    class Authenticator
      include Stormpath::Util::Assert

      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate(parent_href, request)
        assert_not_nil parent_href, "parent_href must be specified"

        grant_class = classes_by_grant_type[request.grant_type.to_sym]
        attempt = @data_store.instantiate(grant_class)
        attempt.set_options(request)

        href = parent_href + '/oauth/token'
        @data_store.create href, attempt, Stormpath::Oauth::AccessTokenAuthenticationResult
      end

      private

      def classes_by_grant_type
        {
          password: PasswordGrant,
          refresh_token: RefreshToken,
          id_site_token: IdSiteGrant
        }
      end
    end
  end
end
