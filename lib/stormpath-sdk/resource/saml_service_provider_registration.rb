module Stormpath
  module Resource
    class SamlServiceProviderRegistration < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at
      prop_accessor :status, :default_relay_state

      has_one :service_provider, class_name: :registeredSamlServiceProvider
      has_one :identity_provider, class_name: :samlIdentityProvider
    end
  end
end
