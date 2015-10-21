module Stormpath
  module Oauth
    class RefreshToken < Stormpath::Resource::Base
      prop_accessor :grant_type, :refresh_token

      def set_options(options)
        set_property :grant_type, options[:body][:grant_type]
        set_property :refresh_token, options[:body][:refresh_token]
      end

      def form_data?
        true
      end
    end
  end
end
