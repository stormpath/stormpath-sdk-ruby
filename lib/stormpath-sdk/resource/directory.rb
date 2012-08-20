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

    class Directory < InstanceResource

      include Status

      NAME = "name"
      DESCRIPTION = "description"
      STATUS = "status"
      ACCOUNTS = "accounts"
      GROUPS = "groups"
      TENANT = "tenant"

      def get_name
        get_property NAME
      end

      def set_name name
        set_property NAME, name
      end

      def get_description
        get_property DESCRIPTION
      end

      def set_description description
        set_property DESCRIPTION, description
      end

      def get_status
        value = get_property STATUS

        if !value.nil?
          value = value.upcase
        end

        value
      end

      def set_status status

        if get_status_hash.has_key? status
          set_property STATUS, get_status_hash[status]
        end

      end

      def create_account account, *registration_workflow_enabled
        accounts = get_accounts
        href = accounts.get_href
        if !registration_workflow_enabled.nil? and !registration_workflow_enabled.empty?
          href += '?registrationWorkflowEnabled=' + registration_workflow_enabled[0].to_s
        end

        data_store.create href, account, Account
      end

      def get_accounts
        get_resource_property ACCOUNTS, AccountList
      end

      def get_groups
        get_resource_property GROUPS, GroupList
      end

      def get_tenant
        get_resource_property TENANT, Tenant
      end

    end

  end
end

