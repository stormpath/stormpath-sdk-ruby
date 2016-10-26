module Stormpath
  module Test
    module RandomResourceNameGenerator
      include UUIDTools

      %w(application directory organization group user).each do |resource|
        define_method "random_#{resource}_name" do |suffix = nil|
          "#{random_string}_#{resource}_#{suffix}"
        end
      end

      def random_name_key(suffix = 'test')
        "#{random_string}-namekey-#{suffix}"
      end

      def random_email
        "#{random_string}@stormpath.com"
      end

      def random_string
        if HIJACK_HTTP_REQUESTS_WITH_VCR
          'test'
        else
          UUID.method(:random_create).call.to_s[0..9]
        end
      end
    end
  end
end
