module Stormpath
  module Oauth
    class PasswordGrantRequest
      attr_accessor :grant_type, :username, :password

      def initialize(username, password)
        @username = username
        @password = password
        @grant_type = "password"
      end
    end
  end
end
