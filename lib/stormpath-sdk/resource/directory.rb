module Stormpath
  module Resource
    class Directory < Stormpath::Resource::Instance
      include Stormpath::Resource::CustomDataStorage
      include Stormpath::Resource::AccountOverrides

      prop_accessor :name, :description, :status
      prop_reader :created_at, :modified_at

      belongs_to :tenant

      has_many :accounts, can: [:get, :create]
      has_many :groups, can: [:get, :create]
      has_many :organizations, can: :get
      has_one :custom_data
      has_one :password_policy
      has_one :account_creation_policy
      has_one :account_schema, class_name: :schema

      delegate :attribute_statement_mapping_rules, to: :provider
      delegate :service_provider_metadata, to: :provider
      delegate :user_info_mapping_rules, to: :provider

      def provider
        internal_instance = instance_variable_get '@_provider'
        return internal_instance if internal_instance

        provider_href = href + '/provider'

        clazz_proc = proc do |data|
          provider_id = data['providerId']
          "Stormpath::Provider::#{provider_id.capitalize}Provider".constantize
        end

        provider = data_store.get_resource provider_href, clazz_proc
        instance_variable_set '@_provider', provider
      end
    end
  end
end
