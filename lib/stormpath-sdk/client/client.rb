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

  module Client

    class Client

      attr_reader :data_store

      def initialize(api_key, *base_url)
        request_executor = Stormpath::Http::HttpClientRequestExecutor.new(api_key)
        @data_store = Stormpath::DataStore::DataStore.new(request_executor, *base_url)
      end


      def current_tenant
        @data_store.get_resource("/tenants/current", Stormpath::Resource::Tenant)
      end
    end
  end


end

