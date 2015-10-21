module Stormpath
  module Jwt
    class Authenticator
      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate parent_href, options
        #TODO add validations here

        att
      end
    end
  end
end
