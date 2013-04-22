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
class  Stormpath::Account < Stormpath::InstanceResource
  include Stormpath::Status

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

  def username
    get_property USERNAME
  end

  def username=(username)
    set_property USERNAME, username
  end

  def email
    get_property EMAIL
  end

  def email=(email)
    set_property EMAIL, email
  end

  def password=(password)
    set_property PASSWORD, password
  end

  def given_name
    get_property GIVEN_NAME
  end

  def given_name=(given_name)
    set_property GIVEN_NAME, given_name
  end

  def middle_name
    get_property MIDDLE_NAME
  end

  def middle_name=(middle_name)
    set_property MIDDLE_NAME, middle_name
  end

  def surname
    get_property SURNAME
  end

  def surname=(surname)
    set_property SURNAME, surname
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

  def groups
    get_resource_property GROUPS, Stormpath::GroupList
  end

  def directory
    get_resource_property DIRECTORY, Stormpath::Directory
  end

  def email_verification_token
    get_resource_property EMAIL_VERIFICATION_TOKEN, Stormpath::EmailVerificationToken
  end

  def add_group group

    Stormpath::GroupMembership::_create self, group, data_store

  end

  def group_memberships
    get_resource_property GROUP_MEMBERSHIPS, Stormpath::GroupMembershipList
  end

  protected
  def printable_property? property_name
    PASSWORD != property_name
  end

end
