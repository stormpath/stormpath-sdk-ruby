module Stormpath
  module Oauth
    class PasswordGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :username, :password

      def form_properties
        {
          grant_type: grant_type,
          username: username,
          password: password
        }
      end

      def set_options(request)
        set_property :username, request.username
        set_property :password, request.password
        set_property :grant_type, request.grant_type
      end

      def form_data?
        true
      end
    end
  end
end
