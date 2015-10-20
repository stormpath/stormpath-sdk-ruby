module Stormpath
  module Oauth
    class PasswordGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :username, :password, :form_data

      def set_options(options)
        set_property :grant_type, options[:grant_type]
        set_property :username, options[:username]
        set_property :password, options[:password]
      end

      def form_data?
        true
      end
    end
  end
end
