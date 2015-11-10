module Stormpath
  module Oauth
    class RefreshGrantRequest 
      attr_accessor :grant_type, :refresh_token

      def initialize(request)
        @refresh_token = request.refresh_token
        @grant_type = "refresh_token" 
      end
    end
  end
end
