module Stormpath
  module Provider
    class LdapProvider < Stormpath::Provider::Provider
      prop_reader :provider_id

      has_one :agent
    end
  end
end
