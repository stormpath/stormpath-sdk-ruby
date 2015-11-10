module Stormpath
  module Oauth 
    class VerifyToken < Stormpath::Resource::Base
      prop_reader :href, :account, :application, :jwt, :tenant, :expanded_jwt
    end
  end
end
