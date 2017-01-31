module Stormpath
  module Resource
    class SamlPolicy < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at

      has_one :identity_provider, class_name: :samlIdentityProvider
      #has_one :service_provider
      # https://stormpath.atlassian.net/wiki/display/AM/Stormpath+as+a+SAML+Service+Provider
    end
  end
end
