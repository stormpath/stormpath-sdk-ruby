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
class Stormpath::Resource::Application < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  class LoadError < Stormpath::Error; end

  prop_accessor :name, :description

  belongs_to :tenant
  has_many :accounts, can: [:create]
  has_many :password_reset_tokens, can: [:get, :create]
  has_many :account_store_mappings, can: [:get, :create]
  has_many :groups, can: :get
  
  has_one :default_account_store_mapping, class_name: :accountStoreMapping
  has_one :default_group_store_mapping, class_name: :accountStoreMapping

  def self.load composite_url
    begin
      uri = URI(composite_url)
      api_key_id, api_key_secret = uri.userinfo.split(':')

      client = Stormpath::Client.new api_key: {
        id: api_key_id,
        secret: api_key_secret
      }

      application_path = uri.path.slice(/\/applications(.)*$/)
      client.applications.get(application_path)
    rescue
      raise LoadError
    end
  end

  def send_password_reset_email email
    password_reset_token = create_password_reset_token email;
    password_reset_token.account
  end

  def verify_password_reset_token token
    password_reset_tokens.get(token).account
  end

  def authenticate_account request, account_store = nil
    response = Stormpath::Authentication::BasicAuthenticator.new data_store
    response.authenticate href, request, account_store
  end

  private

    def create_password_reset_token email
      password_reset_tokens.create email: email
    end

end
