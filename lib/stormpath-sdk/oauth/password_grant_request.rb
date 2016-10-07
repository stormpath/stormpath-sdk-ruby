module Stormpath
  module Oauth
    class PasswordGrantRequest
      attr_accessor :grant_type, :username, :password, :organization_name_key

      def initialize(username, password, options = {})
        @username = username
        @password = password
        @grant_type = "password"
        @organization_name_key = options[:organization_name_key]
      end
    end
  end
end
