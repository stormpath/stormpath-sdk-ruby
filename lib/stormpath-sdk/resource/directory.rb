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
class Stormpath::Resource::Directory < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  prop_accessor :name, :description

  belongs_to :tenant

  has_many :accounts, can: :create
  has_many :groups, can: :create

  def create_account account, registration_workflow_enabled=nil
    href = accounts.href
    unless registration_workflow_enabled.nil?
      href += "?registrationWorkflowEnabled=#{registration_workflow_enabled.to_s}"
    end

    data_store.create href, account, Stormpath::Resource::Account
  end
end
