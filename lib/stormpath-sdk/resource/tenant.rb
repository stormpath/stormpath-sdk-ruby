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
class Stormpath::Tenant < Stormpath::InstanceResource

  NAME = "name"
  KEY = "key"
  APPLICATIONS = "applications"
  DIRECTORIES = "directories"

  def name
    get_property NAME
  end

  def key
    get_property KEY
  end

  def create_application application

    href = "/applications"; #TODO: enable auto discovery
    data_store.create href, application, Stormpath::Application

  end

  def applications
    get_resource_property APPLICATIONS, Stormpath::ApplicationList
  end

  def directories
    get_resource_property DIRECTORIES, Stormpath::DirectoryList
  end

  def verify_account_email token

    #TODO: enable auto discovery via Tenant resource (should be just /emailVerificationTokens)
    href = "/accounts/emailVerificationTokens/" + token

    token_hash = Hash.new
    token_hash.store Stormpath::HREF_PROP_NAME, href

    ev_token = data_store.instantiate Stormpath::EmailVerificationToken, token_hash

    #execute a POST (should clean this up / make it more obvious)
    data_store.save ev_token, Stormpath::Account
  end

end
