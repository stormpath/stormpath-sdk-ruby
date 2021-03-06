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
  module Resource
    class Group < Stormpath::Resource::Instance
      include Stormpath::Resource::CustomDataStorage

      prop_accessor :name, :description, :status
      prop_reader :created_at, :modified_at

      belongs_to :tenant
      belongs_to :directory

      has_many :accounts
      has_many :account_memberships

      has_one :custom_data

      def add_account(account)
        client.group_memberships.create(group: self, account: account)
      end

      def remove_account(account)
        account_membership = account_memberships.find do |membership|
          membership.account.href == account.href
        end
        account_membership.delete if account_membership
      end
    end
  end
end
