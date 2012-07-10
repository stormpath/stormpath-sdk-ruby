require "stormpath-sdk/resource/resource"
require "stormpath-sdk/resource/account"

module Stormpath

  module Resource

    class PasswordResetToken < Resource


      EMAIL = "email"
      ACCOUNT = "account"

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_email
        get_property EMAIL
      end

      def set_email email
        set_property EMAIL, email
      end

      def get_account
        get_resource_property ACCOUNT, Account
      end

    end

  end

end
