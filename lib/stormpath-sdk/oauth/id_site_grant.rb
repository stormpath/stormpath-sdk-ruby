module Stormpath
  module Oauth
    class IdSiteGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :token

      def set_options(request)
        set_property :grant_type, request.grant_type
        set_property :token, request.token
      end

      def form_data?
        true
      end
    end
  end
end
