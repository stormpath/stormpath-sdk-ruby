module Stormpath
  module Oauth
    class SocialGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :provider_id, :code, :access_token, :redirect_uri

      def form_properties
        {
          grant_type: grant_type,
          providerId: provider_id,
          code: code,
          accessToken: access_token,
          redirectUri: redirect_uri
        }
      end

      def set_options(request)
        set_property :provider_id, request.provider_id
        set_property :code, request.code if request.code
        set_property :access_token, request.access_token if request.access_token
        set_property :redirect_uri, request.redirect_uri if request.redirect_uri
        set_property :grant_type, request.grant_type
      end

      def form_data?
        true
      end
    end
  end
end
