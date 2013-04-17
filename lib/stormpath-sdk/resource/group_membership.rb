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
class Stormpath::GroupMembership < Stormpath::Resource

  ACCOUNT = "account"
  GROUP = "group"

  def get_account
    get_resource_property ACCOUNT, Stormpath::Account
  end

  def get_group
    get_resource_property GROUP, Stormpath::Group
  end

  def delete
    data_store.delete self
  end

  #
  # THIS IS NOT PART OF THE STORMPATH PUBLIC API.  SDK end-users should not call it - it could be removed or
  # changed at any time.  It is publicly accessible only as an implementation technique to be used by other
  # resource classes.
  #
  # @param account the account to associate with the group.
  # @param group the group which will contain the account.
  # @param data_store the datastore used to create the membership
  # @return the created GroupMembership instance.
  #
  def self._create account, group, data_store

    #TODO: enable auto discovery
    href = "/groupMemberships"

    account_props = Hash.new
    account_props.store Stormpath::HREF_PROP_NAME, account.get_href

    group_props = Hash.new
    group_props.store Stormpath::HREF_PROP_NAME, group.get_href

    props = Hash.new
    props.store ACCOUNT, account_props
    props.store GROUP, group_props

    group_membership = data_store.instantiate Stormpath::GroupMembership, props

    data_store.create href, group_membership, Stormpath::GroupMembership

  end

end
