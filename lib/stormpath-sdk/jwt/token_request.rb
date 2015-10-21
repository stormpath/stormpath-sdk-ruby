module Stormpath
  module Jwt
    class TokenRequest < Stormpath::Resource::Base
      prop_accessor :authorization

      def set_options(options)
        set_property :authorization, options[:headers][:authorization]
      end
    end
  end
end
