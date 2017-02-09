#
# Copyright 2016 Stormpath, Inc.
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
    class Application < Stormpath::Resource::Instance
      include Stormpath::Resource::CustomDataStorage
      include Stormpath::Resource::AccountOverrides

      include UUIDTools

      class LoadError < ArgumentError; end

      prop_accessor :name, :description, :authorized_callback_uris, :status, :authorized_origin_uris
      prop_reader :created_at, :modified_at

      belongs_to :tenant

      has_many :accounts, can: [:get, :create]
      has_many :password_reset_tokens, can: [:get, :create]
      has_many :account_store_mappings, can: [:get, :create]
      has_many :groups, can: [:get, :create]
      has_many :verification_emails, can: :create
      has_many :api_keys

      has_one :default_account_store_mapping, class_name: :accountStoreMapping
      has_one :default_group_store_mapping, class_name: :accountStoreMapping
      has_one :custom_data
      has_one :o_auth_policy, class_name: :oauthPolicy
      has_one :web_config, class_name: :applicationWebConfig
      has_one :account_linking_policy
      has_one :saml_policy

      alias oauth_policy o_auth_policy

      def self.load(composite_url)
        builder = Stormpath::Util::UriBuilder.new(composite_url)
        api_key_id, api_key_secret = builder.userinfo.split(':')

        client = Stormpath::Client.new(
          api_key: {
            id: api_key_id,
            secret: api_key_secret
          }
        )

        application_path = builder.uri.path.slice(/\/applications(.)*$/)
        client.applications.get(application_path)
      rescue
        raise LoadError
      end

      def create_id_site_url(options = {})
        raise Stormpath::Oauth::Error, :jwt_cb_uri_incorrect if options[:callback_uri].blank?

        base = client.data_store.base_url.sub("v#{Stormpath::DataStore::DEFAULT_API_VERSION}", 'sso')
        base += '/logout' if options[:logout]

        token = JWT.encode(jwt_token_payload(options), client.data_store.api_key.secret, 'HS256')
        "#{base}?jwtRequest=#{token}"
      end

      def handle_id_site_callback(response_url)
        assert_not_nil(response_url, 'No response provided. Please provide response object.')

        uri = URI(response_url)
        params = CGI.parse(uri.query)
        token = params['jwtResponse'].first

        begin
          jwt_response, _header = JWT.decode(token, client.data_store.api_key.secret)
        rescue JWT::ExpiredSignature => error
          # JWT raises error if the signature expired, we need to capture this and
          # reraise IdSite::Error
          raise Stormpath::Oauth::Error, :jwt_expired
        end

        id_site_result = Stormpath::IdSite::IdSiteResult.new(jwt_response)

        raise Stormpath::Oauth::Error, :jwt_invalid if id_site_result.jwt_invalid?(api_key_id)

        id_site_result
      end

      def send_password_reset_email(email, account_store: nil)
        password_reset_token = create_password_reset_token(email, account_store: account_store)
        password_reset_token.account
      end

      def verify_password_reset_token(token)
        password_reset_tokens.get(token).account
      end

      def authenticate_account(request)
        Stormpath::Authentication::BasicAuthenticator.new(data_store).authenticate(href, request)
      end

      def get_provider_account(request)
        Stormpath::Provider::AccountResolver.new(data_store, href, request).resolve_provider_account
      end

      def authenticate_oauth(request)
        Stormpath::Oauth::Authenticator.new(data_store).authenticate(href, request)
      end

      def register_service_provider(options = {})
        Stormpath::Authentication::RegisterServiceProvider.new(
          saml_policy.identity_provider, options
        ).call
      end

      private

      def jwt_token_payload(options)
        {}.tap do |payload|
          payload[:jti] = UUID.method(:random_create).call.to_s
          payload[:iat] = Time.now.to_i
          payload[:iss] = client.data_store.api_key.id
          payload[:sub] = href
          payload[:state] = options[:state] || ''
          payload[:path] = options[:path] || ''
          payload[:cb_uri] = options[:callback_uri]
          payload[:sof] = options[:show_organization_field]
          payload[:onk] = options[:organization_name_key]
          payload[:usd] = options[:use_subdomain]
          payload[:require_mfa] = options[:require_mfa]
        end.compact
      end

      def api_key_id
        client.data_store.api_key.id
      end

      def create_password_reset_token(email, account_store: nil)
        params = { email: email }
        params[:account_store] = account_store_to_hash(account_store) if account_store
        password_reset_tokens.create(params)
      end

      def account_store_to_hash(account_store)
        case account_store
        when Stormpath::Resource::Organization
          { name_key: account_store.name_key }
        when Stormpath::Resource::Group, Stormpath::Resource::Directory
          { href: account_store.href }
        when Hash
          account_store
        else
          raise ArgumentError, 'Account store has to be passed either as an resource or a hash'
        end
      end
    end
  end
end
