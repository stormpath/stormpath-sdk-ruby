class Stormpath::Resource::Organization < Stormpath::Resource::Instance
  include Stormpath::Resource::CustomDataStorage

  prop_accessor :name, :description, :name_key, :status, :account_store_mappings,
                :default_account_store_mapping, :default_group_store_mapping

  prop_reader :created_at, :modified_at

  has_many :groups
  has_many :accounts, can: [:get, :create]
  belongs_to :tenant

  has_one :custom_data
  has_one :account_linking_policy
end
