module Stormpath
  module Jwt
    class Authenticator
      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, options
        href = parent_href + '/authTokens/' + options[:headers][:authorization]
        @data_store.get_resource href, Stormpath::Jwt::AuthenticationResult
      end
    end
  end
end
