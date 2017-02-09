module Stormpath
  module Resource
    class SamlIdentityProvider < Stormpath::Resource::Instance
      prop_reader :sso_login_endpoint, :signature_algorithm, :sha_fingerprint, :created_at, :modified_at
      prop_accessor :status

      has_one :metadata, class_name: :samlIdentityProviderMetadata
      has_one :attribute_statement_mapping_rules
      has_one :x509_signing_cert, class_name: :x509Certificate
      has_many :registered_saml_service_providers
      has_many :saml_service_provider_registrations, can: [:get, :create]

      def register_service_provider(options = {})
        Stormpath::Authentication::RegisterServiceProvider.new(self, options).call
      end
    end
  end
end
