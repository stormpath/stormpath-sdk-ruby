module Stormpath
  module Oauth
    class PasswordGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :username, :password, :organization_name_key

      def form_properties
        {}.tap do |form|
          form[:grant_type] = grant_type
          form[:username] = username
          form[:password] = password
          form[:organizationNameKey] = organization_name_key if organization_name_key.present?
        end
      end

      def set_options(request)
        set_property :grant_type, request.grant_type
        set_property :username, request.username
        set_property :password, request.password
        set_property :organization_name_key, request.organization_name_key
      end

      def form_data?
        true
      end
    end
  end
end
