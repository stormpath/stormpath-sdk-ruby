module Stormpath
  module Oauth
    class Authenticator
      include Stormpath::Util::Assert

      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate(parent_href, request)
        assert_not_nil parent_href, "parent_href must be specified"

        clazz = GRANT_CLASSES_BY_TYPE[request.grant_type.to_sym]
        attempt = @data_store.instantiate(clazz)
        attempt.set_options(request)
        href = parent_href + '/oauth/token'

        @data_store.create href, attempt, Stormpath::Oauth::AccessTokenAuthenticationResult
      end

      GRANT_CLASSES_BY_TYPE = {
        password: PasswordGrant,
        refresh_token: RefreshToken,
        id_site_token: IdSiteGrant,
        stormpath_token: StormpathTokenGrant,
        client_credentials: ClientCredentialsGrant
      }.freeze
    end
  end
end
