module Stormpath

  module Authentication

    class AuthenticationResult < Stormpath::Resource::Resource

      ACCOUNT = "account"

      def initialize dataStore, properties
        super dataStore, properties
      end

      def get_account
        get_resource_property ACCOUNT, Account
      end

    end

  end

end