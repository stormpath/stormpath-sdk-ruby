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
class Stormpath::Resource::Account < Stormpath::Resource::Instance
  include Stormpath::Resource::CustomDataStorage

  prop_accessor :username, :email, :given_name, :middle_name, :surname, :status
  prop_writer :password
  prop_reader :full_name, :created_at, :modified_at, :password_modified_at
  prop_non_printable :password

  belongs_to :directory
  belongs_to :tenant

  has_one :email_verification_token

  has_many :groups
  has_many :group_memberships
  has_many :applications

  has_one :custom_data

  has_many :access_tokens
  has_many :refresh_tokens

  def add_group group
    client.group_memberships.create group: group, account: self
  end

  def remove_group group
    group_membership = group_memberships.find {|group_membership| group_membership.group.href == group.href }
    group_membership.delete if group_membership
  end

  def provider_data
    internal_instance = instance_variable_get "@_provider_data"
    return internal_instance if internal_instance

    provider_data_href = self.href + '/providerData'

    clazz_proc = Proc.new do |data|
      provider_id = data['providerId']
      "Stormpath::Provider::#{provider_id.capitalize}ProviderData".constantize
    end

    provider_data = data_store.get_resource provider_data_href, clazz_proc
    instance_variable_set "@_provider_data", provider_data
  end

end
