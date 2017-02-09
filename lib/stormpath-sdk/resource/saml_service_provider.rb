module Stormpath
  module Resource
    class SamlServiceProvider < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at, :sso_initiation_endpoint
    end
  end
end
