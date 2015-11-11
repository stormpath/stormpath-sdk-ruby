module Stormpath
  module Oauth
    class RefreshGrantRequest 
      attr_accessor :grant_type, :refresh_token

      def initialize(refresh_token)
        @refresh_token = refresh_token
        @grant_type = "refresh_token" 
      end
    end
  end
end
