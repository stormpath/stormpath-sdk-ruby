module Stormpath
  module Resource
    class AccessToken < Stormpath::Resource::Instance
      prop_reader :jwt, :expanded_jwt

      belongs_to :account
      belongs_to :application
      belongs_to :tenant
    end
  end
end
