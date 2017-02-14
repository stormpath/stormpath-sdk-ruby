module Stormpath
  module Util
    class HrefQualifier
      attr_reader :base_url

      def initialize(base_url)
        @base_url = base_url
      end

      def qualify(href)
        invalid_href?(href) ? "#{base_url}#{href}" : href
      end

      private

      def invalid_href?(href)
        !href.downcase.start_with?('http')
      end
    end
  end
end
