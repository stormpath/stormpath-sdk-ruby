module Stormpath
  module Oauth
    class IdSiteGrantRequest
      attr_accessor :grant_type, :token

      def initialize(token)
        @token = token
        @grant_type = 'id_site_token'
      end
    end
  end
end
