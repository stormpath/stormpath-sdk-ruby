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
class Stormpath::Resource::GroupMemberships < Stormpath::Resource::Collection

  def item_type
    Stormpath::Resource::GroupMembership
  end

  def create(group, account)
    account_props = Hash.new
    account_props.store Stormpath::Resource::Base::HREF_PROP_NAME, account.href

    group_props = Hash.new
    group_props.store Stormpath::Resource::Base::HREF_PROP_NAME, group.href

    props = Hash.new
    props.store 'account', account_props
    props.store 'group', group_props

    group_membership = Stormpath::Resource::GroupMembership.new props, client
    data_store.create href, group_membership, item_type
  end

end
