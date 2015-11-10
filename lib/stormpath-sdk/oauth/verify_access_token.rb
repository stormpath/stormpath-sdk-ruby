module Stormpath
  module Oauth
    class VerifyAccessToken
      def initialize(data_store)
        @data_store = data_store
      end

      def verify href, authorization_token
        href = href + '/authTokens/' + authorization_token 
        @data_store.get_resource href, VerifyToken 
      end
    end
  end
end
