module Stormpath
  module Resource
    class SamlServiceProviderRegistration < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at
      prop_accessor :status, :default_relay_state
    end
  end
end
