module Stormpath
  module Oauth
    class ClientCredentialsGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :api_key_id, :api_key_secret

      def form_properties
        {
          grant_type: grant_type,
          apiKeyId: api_key_id,
          apiKeySecret: api_key_secret
        }
      end

      def set_options(request)
        set_property :api_key_id, request.api_key_id
        set_property :api_key_secret, request.api_key_secret
        set_property :grant_type, request.grant_type
      end

      def form_data?
        true
      end
    end
  end
end
