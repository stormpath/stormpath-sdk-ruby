module Stormpath

  module Resource

    class Directory < InstanceResource

      include Status

      NAME = "name"
      DESCRIPTION = "description"
      STATUS = "status"
      ACCOUNTS = "accounts"
      GROUPS = "groups"
      TENANT = "tenant"

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

        if (get_status_hash.has_key? status)
          set_property STATUS, get_status_hash[status]
        end

      end

      def create_account account, registrationWorkflowEnabled
        accounts = get_accounts
        href = accounts.get_href
        if (registrationWorkflowEnabled)
          href += "?registrationWorkflowEnabled=" + registrationWorkflowEnabled
        end

        dataStore.create href, account, Account
      end

      def get_accounts
        get_resource_property ACCOUNTS, AccountList
      end

      def get_groups
        get_resource_property GROUPS, GroupList
      end

      def get_tenant
        get_resource_property TENANT, Tenant
      end

    end

  end
end

