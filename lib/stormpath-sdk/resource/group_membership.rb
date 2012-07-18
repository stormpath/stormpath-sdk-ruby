module Stormpath

  module Resource

    class GroupMembership < InstanceResource

      ACCOUNT = "account"
      GROUP = "group"

      def initialize dataStore, properties
        super dataStore, properties
      end

      def get_account
        get_resource_property ACCOUNT, Account
      end

      def set_account account
        set_property ACCOUNT, account
      end

      def get_group
        get_resource_property GROUP, Group
      end

      def set_group group
        set_property GROUP, group
      end

      def create account, group

        #TODO: enable auto discovery
        String href = "/groupMemberships"

        accountProps = Hash.new
        accountProps.store HREF_PROP_NAME, account.get_href

        groupProps = Hash.new
        groupProps.store HREF_PROP_NAME, group.get_href

        props = Hash.new
        props.store ACCOUNT, accountProps
        props.store GROUP, groupProps

        groupMemberShip = dataStore.instantiate GroupMembership, props

        dataStore.create href, groupMemberShip, GroupMembership

      end

      def delete
        dataStore.delete self
      end

    end

  end

end