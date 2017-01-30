module Stormpath
  module Resource
    class SamlServiceProviderRegistration < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at
      prop_accessor :status

      has_one :service_provider, :registeredSamlServiceProvider
      # TODO: check these 2 attributes out
      #  "identityProvider": { "href": "..." },
      #  "defaultRelayState": "..."
    end
  end
end
