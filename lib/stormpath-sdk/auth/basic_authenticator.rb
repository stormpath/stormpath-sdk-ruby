module Stormpath

  module Authentication

    class BasicAuthenticator

      include Stormpath::Util::Assert

      def initialize data_store
        @data_store = data_store
      end

      def authenticate parent_href, request

        assert_not_nil parent_href, "parentHref argument must be specified"
        assert_kind_of UsernamePasswordRequest, request, "Only UsernamePasswordRequest instances are supported."

        username = request.get_principals
        username = (username != nil) ? username : ''

        password = request.get_credentials
        pw_string = password.to_s

        value = username + ':' + pw_string

        value = Base64.encode64(value).tr("\n", '')

        attempt = @data_store.instantiate BasicLoginAttempt, nil
        attempt.set_type 'basic'
        attempt.set_value value

        href = parent_href + '/loginAttempts'
        result = @data_store.create href, attempt, AuthenticationResult
        result.get_account

      end

    end

  end

end