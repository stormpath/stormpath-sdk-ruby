module Stormpath

  module Resource

    class Application < InstanceResource

      include Status

      NAME = "name"
      DESCRIPTION = "description"
      STATUS = "status"
      TENANT = "tenant"
      ACCOUNTS = "accounts"
      PASSWORD_RESET_TOKENS = "passwordResetTokens"

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

        if !value.nil?
          value = value.upcase
        end

        value
      end

      def set_status status

        if get_status_hash.has_key? status
          set_property STATUS, get_status_hash[status]
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

      def create_password_reset_token email

        href = get_password_reset_token.get_href

        password_reset_props = Hash.new
        password_reset_props.store 'email', email

        password_reset_token = data_store.instantiate PasswordResetToken, password_reset_props

        data_store.create href, password_reset_token, PasswordResetToken

      end

      def verify_password_reset_token token

        href = get_password_reset_token.get_href
        href += '/' + token

        data_store.get_resource href, PasswordResetToken

      end

      def authenticate request
        response = Stormpath::Authentication::BasicAuthenticator.new data_store
        response.authenticate get_href, request
      end

    end

  end

end

