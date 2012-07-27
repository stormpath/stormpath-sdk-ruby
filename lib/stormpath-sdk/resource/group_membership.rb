module Stormpath

  module Resource

    class GroupMembership < InstanceResource

      ACCOUNT = "account"
      GROUP = "group"

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

        account_props = Hash.new
        account_props.store HREF_PROP_NAME, account.get_href

        group_props = Hash.new
        group_props.store HREF_PROP_NAME, group.get_href

        props = Hash.new
        props.store ACCOUNT, account_props
        props.store GROUP, group_props

        group_membership = data_store.instantiate GroupMembership, props

        data_store.create href, group_membership, GroupMembership

      end

      def delete
        data_store.delete self
      end

    end

  end

end