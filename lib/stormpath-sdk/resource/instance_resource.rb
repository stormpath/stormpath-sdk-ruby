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
class Stormpath::InstanceResource < Stormpath::Resource
  class << self
    def parent_uri
      raise 'You need to define a URI path to the recource API base'
    end

    def create(in_data_store_or_client, properties={})
      data_store = resolve_data_store in_data_store_or_client
      instance = new(data_store, properties)
      data_store.create parent_uri, instance, self
    end

    def get(from_data_store_or_client, id_or_uri)
      data_store = resolve_data_store from_data_store_or_client
      data_store.get_resource id_or_uri, self
    end

    private

    def resolve_data_store(data_store_or_client)
      case data_store_or_client
      when Stormpath::DataStore
        data_store_or_client
      when Stormpath::Client
        data_store_or_client.data_store
      end
    end
  end

  def save
    if is_new
      data_store.create parent_uri, self, self.class
    else
      data_store.save self
    end
  end

  def delete
    unless is_new
      data_store.delete self
    end
  end
end
