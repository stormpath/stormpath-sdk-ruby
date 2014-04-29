module Stormpath
  module Authentication
    class GoogleAccountRequest < ProviderAccountRequest

        def initialize(token_type, token_value)
          super(:google, token_type, token_value)
        end

    end
  end
end