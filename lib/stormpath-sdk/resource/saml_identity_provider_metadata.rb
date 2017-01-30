module Stormpath
  module Resource
    class SamlIdentityProviderMetadata < Stormpath::Resource::Instance
      prop_reader :entity_id
      belongs_to :identity_provider, class_name: :samlIdentityProvider
      has_one :x509_signing_cert, class_name: :x509Certificate
    end
  end
end
