require "stormpath-sdk/resource/instance_resource"
require "stormpath-sdk/resource/tenant"
require "stormpath-sdk/resource/account_list"
require "stormpath-sdk/resource/password_reset_token"
require "stormpath-sdk/auth/basic_authenticator"

module Stormpath

  module Resource

    class Application < InstanceResource


      NAME = "name"
      DESCRIPTION = "description"
      STATUS = "status"
      TENANT = "tenant"
      ACCOUNTS = "accounts"
      PASSWORD_RESET_TOKENS = "passwordResetTokens"


      def initialize dataStore, properties
        super dataStore, properties
      end

      def get_name
        get_property NAME
      end

      def set_name name
        set_property NAME, name
      end

      def get_description
        get_property DESCRIPTION
      end

      def set_description description
        set_property DESCRIPTION, description
      end

      def get_status
        value = get_property STATUS

        if (!value.nil?)
          value = value.upcase
        end

        value
      end

      def set_status status

        if (!status.nil?)
          set_property STATUS, status.upcase
        end

      end

      def get_tenant
        get_resource_property TENANT, Tenant
      end

      def get_accounts

        get_resource_property ACCOUNTS, AccountList
      end

      def get_password_reset_token
        get_resource_property PASSWORD_RESET_TOKENS, PasswordResetToken
      end

      def authenticate request
        response = BasicAuthenticator.new dataStore
        response.authenticate get_href, request
      end

    end

  end

end

