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
class Stormpath::Directory < Stormpath::InstanceResource

  include Stormpath::Status

  def self.parent_uri
    '/directories'
  end

  NAME = "name"
  DESCRIPTION = "description"
  STATUS = "status"
  ACCOUNTS = "accounts"
  GROUPS = "groups"
  TENANT = "tenant"

  def name
    get_property NAME
  end

  def name=(name)
    set_property NAME, name
  end

  def description
    get_property DESCRIPTION
  end

  def description=(description)
    set_property DESCRIPTION, description
  end

  def status
    value = get_property STATUS

    if !value.nil?
      value = value.upcase
    end

    value
  end

  def status=(status)

    if status_hash.has_key? status
      set_property STATUS, status_hash[status]
    end

  end

  def create_account account, *registration_workflow_enabled
    dir_accounts = accounts
    href = dir_accounts.href
    if !registration_workflow_enabled.nil? and !registration_workflow_enabled.empty?
      href += '?registrationWorkflowEnabled=' + registration_workflow_enabled[0].to_s
    end

    data_store.create href, account, Stormpath::Account
  end

  def accounts
    get_resource_property ACCOUNTS, Stormpath::AccountList
  end

  def groups
    get_resource_property GROUPS, Stormpath::GroupList
  end

  def tenant
    get_resource_property TENANT, Stormpath::Tenant
  end

end
