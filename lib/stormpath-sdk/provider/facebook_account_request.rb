module Stormpath
  module Provider
    class FacebookAccountRequest < ProviderAccountRequest

        def initialize(token_type, token_value)
          super(:facebook, token_type, token_value)
        end

    end
  end
end