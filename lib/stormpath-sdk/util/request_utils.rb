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
      def default_port? uri
        scheme = uri.scheme.downcase
        port = uri.port
        port <= 0 || (port == 80 && scheme.eql?("http")) || (port == 443 && scheme.eql?("https"))
      end

      def encode_url value, path, canonical

        encoded = URI.escape value

        if canonical
          encoded['+'] = '%20'
          encoded['*'] = '%2A'
          encoded['%7E'] = '~' # yes, this is reversed (compared to the 2 above) intentionally

          if path
            encoded['%2F'] = '/'
          end

        end

        encoded

      end

    end

  end

end
