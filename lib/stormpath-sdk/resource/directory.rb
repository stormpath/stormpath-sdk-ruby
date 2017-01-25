#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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

      def provider_metadata
        metadata_href = provider.service_provider_metadata['href']
        data_store.get_resource metadata_href, Stormpath::Provider::SamlProviderMetadata
      end

      def statement_mapping_rules
        metadata_href = provider.attribute_statement_mapping_rules['href']
        data_store.get_resource metadata_href, Stormpath::Provider::SamlMappingRules
      end

      def create_attribute_mappings(mappings)
        mappings.set_options(href: provider.attribute_statement_mapping_rules['href'])
        data_store.create mappings.href, mappings, Stormpath::Provider::SamlMappingRules
      end
    end
  end
end
