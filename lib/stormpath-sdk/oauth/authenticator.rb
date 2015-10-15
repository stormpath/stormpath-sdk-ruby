module Stormpath
  module Oauth
    class Authenticator
      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, options
        #TODO maybe add here some validations

        attempt = @data_store.instantiate PasswordGrant
        attempt.set_options(options)
        
        href = parent_href + '/oauth/token'
        @data_store.create href, attempt, Stormpath::Oauth::AccessTokenResponse
      end
    end
  end
end
