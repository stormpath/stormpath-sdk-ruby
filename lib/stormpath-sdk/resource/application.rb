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
  include Stormpath::Resource::CustomDataStorage
  include Stormpath::Resource::AccountOverrides
  include UUIDTools

  class LoadError < Stormpath::Error; end

  prop_accessor :name, :description

  belongs_to :tenant

  has_many :accounts, can: [:get, :create]
  has_many :password_reset_tokens, can: [:get, :create]
  has_many :account_store_mappings, can: [:get, :create]
  has_many :groups, can: [:get, :create]
  has_many :verification_emails, can: :create

  has_one :default_account_store_mapping, class_name: :accountStoreMapping
  has_one :default_group_store_mapping, class_name: :accountStoreMapping
  has_one :custom_data
  has_one :o_auth_policy, class_name: :oauthPolicy

  alias_method :oauth_policy, :o_auth_policy

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

  def create_id_site_url(options = {})
    base = client.data_store.base_url.sub("v" + Stormpath::DataStore::DEFAULT_API_VERSION.to_s, "sso")
    base += '/logout' if options[:logout]

    if options[:callback_uri].empty?
      raise Stormpath::IdSite::Error.new(:jwt_cb_uri_incorrect)
    end

    token = JWT.encode(jwt_token_payload(options), client.data_store.api_key.secret, 'HS256')
    base + '?jwtRequest=' + token
  end

  def handle_id_site_callback(response_url)
    assert_not_nil response_url, "No response provided. Please provide response object."

    uri = URI(response_url)
    params = CGI::parse(uri.query)
    token = params["jwtResponse"].first

    begin
      jwt_response, _header = JWT.decode(token, client.data_store.api_key.secret)
    rescue JWT::ExpiredSignature => error
      # JWT raises error if the signature expired, we need to capture this and
      # rerase IdSite::Error
      raise Stormpath::IdSite::Error.new(:jwt_expired)
    end

    id_site_result = Stormpath::IdSite::IdSiteResult.new(jwt_response)

    if id_site_result.jwt_invalid?(api_key_id)
      raise Stormpath::IdSite::Error.new(:jwt_invalid)
    end

    id_site_result
  end

  def send_password_reset_email email
    password_reset_token = create_password_reset_token email;
    password_reset_token.account
  end

  def verify_password_reset_token token
    password_reset_tokens.get(token).account
  end

  def authenticate_account request
    Stormpath::Authentication::BasicAuthenticator.new(data_store).authenticate(href, request)
  end

  def get_provider_account request
    Stormpath::Provider::AccountResolver.new(data_store).resolve_provider_account(href, request)
  end

  def authenticate_oauth(request)
    Stormpath::Oauth::Authenticator.new(data_store).authenticate(href, request) 
  end
  
  private

  def jwt_token_payload(options)
    payload = {
      'iat' => Time.now.to_i,
      'jti' => UUID.method(:random_create).call.to_s,
      'iss' => client.data_store.api_key.id,
      'sub' => href,
      'cb_uri' => options[:callback_uri],
      'path' => options[:path] || '',
      'state' => options[:state] || '',
    }

    payload["sof"] = options[:show_organization_field] if options[:show_organization_field]
    payload["onk"] = options[:organization_name_key] if options[:organization_name_key]
    payload["usd"] = options[:use_subdomain] if options[:use_subdomain]
    payload
  end

  def api_key_id
    client.data_store.api_key.id
  end

  def create_password_reset_token email
    password_reset_tokens.create email: email
  end
end
