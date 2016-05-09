#
# Copyright 2013 Stormpath, Inc.
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
require 'java_properties'

module Stormpath
  class Client
    include Stormpath::Util::Assert
    include Stormpath::Resource::Associations

    attr_reader :data_store, :application

    def initialize(options)
      base_url = options[:base_url]
      cache_opts = options[:cache] || {}

      api_key = ApiKey(options)

      assert_not_nil api_key, "No API key has been provided. Please pass an 'api_key' or " +
                              "'api_key_file_location' to the Stormpath::Client constructor."

      request_executor = Stormpath::Http::HttpClientRequestExecutor.new(proxy: options[:proxy])
      @data_store = Stormpath::DataStore.new(request_executor, api_key, cache_opts, self, base_url)
    end

    def tenant(expansion = nil)
      tenants.get 'current', expansion
    end

    def client
      self
    end

    has_many :tenants, href: '/tenants', can: :get
    has_many :applications, href: '/applications', can: [:get, :create], delegate: true
    has_many :directories, href: '/directories', can: [:get, :create], delegate: true
    has_many :accounts, href: '/accounts', can: :get do
      def verify_email_token(token)
        token_href = "#{href}/emailVerificationTokens/#{token}"
        token = Stormpath::Resource::EmailVerificationToken.new token_href, client
        data_store.save token, Stormpath::Resource::Account
      end
    end
    has_many :organizations, href: '/organizations', can: [:get, :create]
    has_many :groups, href: '/groups', can: :get
    has_many :group_memberships, href: '/groupMemberships', can: [:get, :create]
    has_many :account_store_mappings, href: '/accountStoreMappings', can: [:get, :create]
    has_many :organization_account_store_mappings, href: '/organizationAccountStoreMappings', can: [:get, :create]
    has_many :access_tokens, href: '/accessTokens', can: [:get]
    has_many :refresh_tokens, href: '/refreshTokens', can: [:get]

    private

      def ApiKey(options={})
        if api_key = options[:api_key]
          case api_key
          when ApiKey then api_key
          when Hash then ApiKey.new api_key[:id], api_key[:secret]
          end
        elsif options[:api_key_file_location]
          load_api_key_file(options[:api_key_file_location],
                            options[:api_key_id_property_name],
                            options[:api_key_secret_property_name])
        end
      end

      def load_api_key_file api_key_file_location, id_property_name, secret_property_name
        begin
          api_key_properties = JavaProperties::Properties.new api_key_file_location
        rescue
          raise ArgumentError, "No API Key file could be found or loaded from '#{api_key_file_location}'."
        end

        id_property_name ||= 'apiKey.id'
        secret_property_name ||= 'apiKey.secret'

        api_key_id = api_key_properties[id_property_name]
        assert_not_nil api_key_id, api_key_warning_message(:id, api_key_file_location)

        api_key_secret = api_key_properties[secret_property_name]
        assert_not_nil api_key_secret, api_key_warning_message(:secret, api_key_file_location)

        ApiKey.new api_key_id, api_key_secret
      end

      def api_key_warning_message id_or_secret, api_key_file_location
        "No API #{id_or_secret} in properties. Please provide a 'apiKey.#{id_or_secret}' property " +
        "in '#{api_key_file_location}' or pass in an 'api_key_#{id_or_secret}_property_name' " +
        "to the Stormpath::Client constructor to specify an alternative property."
      end

  end
end
