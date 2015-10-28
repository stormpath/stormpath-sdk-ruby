module Stormpath
  module Oauth
    class Authenticator
      include Stormpath::Util::Assert

      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, options
        assert_not_nil parent_href, "parent_href must be specified"

        if options[:body][:grant_type] == 'password'
          attempt = @data_store.instantiate PasswordGrant
        elsif options[:body][:grant_type] == 'refresh_token'
          attempt = @data_store.instantiate RefreshToken
        end

        attempt.set_options(options)
        
        href = parent_href + '/oauth/token'
        @data_store.create href, attempt, Stormpath::Resource::AccessToken
      end
    end
  end
end
