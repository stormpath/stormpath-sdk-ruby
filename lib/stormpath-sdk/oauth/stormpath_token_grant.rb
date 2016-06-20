module Stormpath
  module Oauth
    class StormpathTokenGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :refresh_token

      def set_options(request)
        set_property :token, request.token
        set_property :grant_type, request.grant_type
      end

      def form_data?
        true
      end
    end
  end
end
