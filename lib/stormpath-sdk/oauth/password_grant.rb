module Stormpath
  module Oauth
    class PasswordGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :username, :password, :form_data

      def set_options(options)
        set_property :grant_type, options[:body][:grant_type]
        set_property :username, options[:body][:username]
        set_property :password, options[:body][:password]
      end

      def form_data?
        true
      end
    end
  end
end
