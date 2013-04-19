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
require 'java_properties'

module Stormpath

  class Client
    include Stormpath::Util::Assert

    attr_reader :data_store, :application

    def initialize(options)
      application_url = options[:application_url]
      api_key = options[:api_key]
      application_path = nil
      base_url = options[:base_url]

      if application_url
        uri = URI(options[:application_url])
        if uri.userinfo
          api_key_id, api_key_secret = uri.userinfo.split(":")
          api_key = ApiKey.new api_key_id, api_key_secret
        end
        application_path = uri.path.slice(/\/applications(.)*$/)
      end

      api_key = if api_key
                  case api_key
                  when ApiKey then api_key
                  when Hash then ApiKey.new api_key[:id], api_key[:secret]
                  end
                elsif options[:api_key_file_location]
                  load_api_key_file options[:api_key_file_location],
                    options[:api_key_id_property_name],
                    options[:api_key_secret_property_name]
                end

      assert_not_nil api_key, "No API key has been provided.  Please " +
          "pass an 'api_key' or 'api_key_file_location' to the " +
          "Stormpath::Client constructor."

      request_executor = Stormpath::Http::HttpClientRequestExecutor.new(api_key)
      @data_store = Stormpath::DataStore.new(request_executor, base_url)

      if application_path
        @application = @data_store.get_resource(application_path, Stormpath::Application)
      end
    end

    def current_tenant
      @data_store.get_resource("/tenants/current", Stormpath::Tenant)
    end

    private

    def load_api_key_file(api_key_file_location, id_property_name, secret_property_name)
      begin
        api_key_properties = JavaProperties::Properties.new api_key_file_location
      rescue
        raise ArgumentError,
          "No API Key file could be found or loaded from '" +
          api_key_file_location +
          "'."
      end

      id_property_name ||= 'apiKey.id'
      secret_property_name ||= 'apiKey.secret'

      api_key_id = api_key_properties[id_property_name]
      assert_not_nil api_key_id,
        "No API id in properties. Please provide a 'apiKey.id' property in '" +
        api_key_file_location +
        "' or pass in an 'api_key_id_property_name' to the Stormpath::Client " +
        "constructor to specify an alternative propeety."

      api_key_secret = api_key_properties[secret_property_name]
      assert_not_nil api_key_secret,
        "No API secret in properties. Please provide a 'apiKey.secret' property in '" +
        api_key_file_location +
        "' or pass in an 'api_key_secret_property_name' to the Stormpath::Client " +
        "constructor to specify an alternative propeety."

      ApiKey.new api_key_id, api_key_secret
    end

  end

end

