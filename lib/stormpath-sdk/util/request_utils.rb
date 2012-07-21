module Stormpath

  module Util

    class RequestUtils

      ##
      # Returns true if the specified URI uses a standard port (i.e. http == 80 or https == 443),
      # false otherwise.
      #
      # param uri
      # return true if the specified URI is using a non-standard port, false otherwise
      #
      def self.default_port? uri
        scheme = uri.scheme.downcase
        port = uri.port
        port <= 0 || (port == 80 && scheme.eql?("http")) || (port == 443 && scheme.eql?("https"))
      end

      def self.encode_url value, path, canonical

        encoded = URI.escape value

        if canonical

          strMap = {'+' => '%20', '*' => '%2A', '%7E' => '~'}

          strMap.each do |key, value|

            if encoded.include? key
              encoded[key] = value
            end

          end

          # encoded['%7E'] = '~'  --> yes, this is reversed (compared to the other two) intentionally

          if path

            str = '%2F'
            if encoded.include? str
              encoded[str] = '/'
            end

          end

        end

        encoded

      end

    end

  end

end
