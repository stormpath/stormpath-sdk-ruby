require "stormpath-sdk/resource/instance_resource"
require "stormpath-sdk/resource/tenant"
require "stormpath-sdk/resource/directory"
require "stormpath-sdk/resource/account_list"

module Stormpath

  module Resource

    class Group < InstanceResource

      NAME = "name"
      DESCRIPTION = "description"
      STATUS = "status"
      TENANT = "tenant"
      DIRECTORY = "directory"
      ACCOUNTS = "accounts"

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

      def get_directory
        get_resource_property DIRECTORY, Directory
      end

      def get_accounts
        get_resource_property ACCOUNTS, AccountList
      end

    end

  end

end
