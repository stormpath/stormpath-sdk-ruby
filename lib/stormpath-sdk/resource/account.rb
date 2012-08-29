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

    class Account < InstanceResource

      include Status

      USERNAME = "username"
      EMAIL = "email"
      PASSWORD = "password"
      GIVEN_NAME = "givenName"
      MIDDLE_NAME = "middleName"
      SURNAME = "surname"
      STATUS = "status"
      GROUPS = "groups"
      DIRECTORY = "directory"
      EMAIL_VERIFICATION_TOKEN = "emailVerificationToken"
      GROUP_MEMBERSHIPS = "groupMemberships"

      def get_username
        get_property USERNAME
      end

      def set_username username
        set_property USERNAME, username
      end

      def get_email
        get_property EMAIL
      end

      def set_email email
        set_property EMAIL, email
      end

      def set_password password
        set_property PASSWORD, password
      end

      def get_given_name
        get_property GIVEN_NAME
      end

      def set_given_name given_name
        set_property GIVEN_NAME, given_name
      end

      def get_middle_name
        get_property MIDDLE_NAME
      end

      def set_middle_name middle_name
        set_property MIDDLE_NAME, middle_name
      end

      def get_surname
        get_property SURNAME
      end

      def set_surname surname
        set_property SURNAME, surname
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

      def get_groups
        get_resource_property GROUPS, GroupList
      end

      def get_directory
        get_resource_property DIRECTORY, Directory
      end

      def get_email_verification_token
        get_resource_property EMAIL_VERIFICATION_TOKEN, EmailVerificationToken
      end

      def add_group group

        group_membership = data_store.instantiate GroupMembership, nil
        group_membership.create self, group

      end

      def get_group_memberships
        get_resource_property GROUP_MEMBERSHIPS, GroupMembershipList
      end

      protected
      def printable_property? property_name
        PASSWORD != property_name
      end

    end

  end

end
