module Stormpath
  module Oauth
    class VerifyAccessToken
      def initialize(application)
        @href = application.href
        @data_store = application.client.data_store
      end

      def verify authorization_token
        href = @href + '/authTokens/' + authorization_token 
        @data_store.get_resource href, VerifyToken 
      end
    end
  end
end
