module Stormpath
  module Authentication
    class ProviderAccountRequest

      attr_accessor :provider, :token_type, :token_value

      def initialize(provider, token_type, token_value) 
        @provider = provider
        @token_type = token_type
        @token_value = token_value
      end

    end
  end
end