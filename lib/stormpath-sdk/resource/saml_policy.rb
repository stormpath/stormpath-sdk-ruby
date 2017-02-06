module Stormpath
  module Resource
    class SamlPolicy < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at

      has_one :service_provider, class_name: :samlServiceProvider
      has_one :identity_provider, class_name: :samlIdentityProvider
    end
  end
end
