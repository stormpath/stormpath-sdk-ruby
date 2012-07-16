module Stormpath

  module Authentication

    class BasicAuthenticator

      include Stormpath::Util::Assert

      def initialize dataStore
        @dataStore = dataStore
      end

      def authenticate parentHref, request

        assert_not_nil parentHref, "parentHref argument must be specified"
        assert_kind_of UsernamePasswordRequest, request, "Only UsernamePasswordRequest instances are supported."

        username = request.get_principals
        username = (username != nil) ? username : ''

        password = request.get_credentials
        pwString = password.to_s

        value = username + ':' + pwString

        value = Base64.encode64(value).tr("\n", '')

        attempt = @dataStore.instantiate BasicLoginAttempt, nil
        attempt.set_type 'basic'
        attempt.set_value value

        href = parentHref + '/loginAttempts'
        result = @dataStore.create href, attempt, AuthenticationResult
        result.get_account

      end

    end

  end

end