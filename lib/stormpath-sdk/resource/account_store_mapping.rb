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
class Stormpath::Resource::AccountStoreMapping < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  prop_accessor :list_index, :is_default_account_store, :is_default_group_store

  belongs_to :application

  def account_store
     account_store_is_a_directory? ? client.directories.get(account_store_href) : client.groups.get(account_store_href)
  end

  alias_method :default_account_store, :is_default_account_store
  alias_method :default_account_store?, :is_default_account_store
  alias_method :default_group_store, :is_default_group_store
  alias_method :default_group_store?, :is_default_group_store
  alias_method :default_account_store=, :is_default_account_store=
  alias_method :default_group_store=, :is_default_group_store=

  private

    def account_store_href
      get_property("accountStore")["href"]
    end
    
    def account_store_is_a_directory?
      /directories/.match account_store_href
    end

end

