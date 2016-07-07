module Stormpath
  module Oauth
    class RefreshToken < Stormpath::Resource::Base
      prop_accessor :grant_type, :refresh_token

      def form_properties
        {
          grant_type: grant_type,
          refresh_token: refresh_token
        }
      end

      def set_options(request)
        set_property :refresh_token, request.refresh_token
        set_property :grant_type, request.grant_type
      end

      def form_data?
        true
      end
    end
  end
end
