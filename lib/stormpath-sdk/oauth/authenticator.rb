module Stormpath
  module Oauth
    class Authenticator
      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, options
        #TODO maybe add here some validations

        if options[:body][:grant_type] == 'password'
          attempt = @data_store.instantiate PasswordGrant
        elsif options[:body][:grant_type] == 'refresh_token'
          attempt = @data_store.instantiate RefreshToken
        end

        attempt.set_options(options)
        
        href = parent_href + '/oauth/token'
        @data_store.create href, attempt, Stormpath::Oauth::AccessTokenResponse
      end
    end
  end
end
