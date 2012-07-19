module Stormpath

  module Http

    module Authc


      class Sauthc1Signer

        DEFAULT_ENCODING = "UTF-8"
        HOST_HEADER = "Host"
        AUTHORIZATION_HEADER = "Authorization"
        STORMAPTH_DATE_HEADER = "X-Stormpath-Date"
        ID_TERMINATOR = "sauthc1_request"
        ALGORITHM = "HMAC-SHA-256"
        AUTHENTICATION_SCHEME = "SAuthc1"
        SAUTHC1_ID = "sauthc1Id"
        SAUTHC1_SIGNED_HEADERS = "sauthc1SignedHeaders"
        SAUTHC1_SIGNATURE = "sauthc1Signature"

        DATE_FORMAT = "yyyyMMdd"
        TIMESTAMP_FORMAT = "yyyyMMdd'T'HHmmss'Z'"
        TIME_ZONE = "UTC"

        NL = "\n"

        private

        def create_name_value_pair name, value
          name + '=' + value
        end


      end

    end

  end

end
