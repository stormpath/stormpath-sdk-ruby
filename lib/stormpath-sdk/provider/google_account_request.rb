module Stormpath
  module Provider
    class GoogleAccountRequest < ProviderAccountRequest

        def initialize(token_type, token_value)
          super(:google, token_type, token_value)
        end

    end
  end
end