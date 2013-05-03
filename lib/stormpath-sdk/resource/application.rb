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

  prop_accessor :name, :description

  resource_prop_reader :tenant, :accounts, :password_reset_tokens

  def send_password_reset_email email
    password_reset_token = create_password_reset_token email;
    password_reset_token.account
  end

  def verify_password_reset_token token
    password_reset_tokens.get(token).account
  end

  def authenticate_account request
    response = Stormpath::Authentication::BasicAuthenticator.new data_store
    response.authenticate href, request
  end

  private

  def create_password_reset_token email
    password_reset_tokens.create email: email
  end
end
