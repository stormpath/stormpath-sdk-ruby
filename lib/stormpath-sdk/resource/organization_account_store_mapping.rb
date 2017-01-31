module Stormpath
  module Resource
    class OrganizationAccountStoreMapping < Stormpath::Resource::Instance
      prop_accessor :is_default_account_store, :is_default_group_store, :list_index

      belongs_to :organization
      belongs_to :account_store
    end
  end
end
