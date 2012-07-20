module Stormpath

  module Http

    module Authc

      class Sauthc1Signer

        DEFAULT_ENCODING = "UTF-8"
        DEFAULT_ALGORITHM = "SHA256"
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


        def to_hex data

          result = ''
          data.each_byte { |val|

            hex = val.to_s(16)

            if hex.length == 1

              result << '0'

            elsif hex.length == 8

              hex = hex[0..6]
            end

            result << hex

          }

          result

        end

        #protected

        def canonicalize_query_string request
          '' #TODO: implement
        end

        def hash text
          OpenSSL::Digest.digest DEFAULT_ALGORITHM, to_utf8(text)
        end

        def sign data, key, algorithm

          data = to_utf8 data

          digest = OpenSSL::Digest::Digest.new(algorithm)

          OpenSSL::HMAC.digest(digest, key, data)

        end

        def to_utf8 str
          str.scan(/./mu).join
        end

        def get_request_payload request
          get_request_payload_without_query_params request
        end

        def get_request_payload_without_query_params request

          result = ''

          if !request.body.nil?
            result = request.body
          end

          result

        end

        #private

        def create_name_value_pair name, value
          name + '=' + value
        end

        def canonicalize_resource_path resourcePath

          if (resourcePath.nil? or resourcePath.empty?)
            return '/'
          else
            return RequestUtils.encode_url resourcePath, true, true
          end
        end


        def canonicalize_headers request

          sortedHeaders = request.httpHeaders.keys.sort!

          result = ''

          sortedHeaders.each do |header|

            result << header << ':' << request.httpHeaders[header] << ','

          end

          result << NL

        end

        def get_signed_headers request

          sortedHeaders = request.httpHeaders.keys.sort!

          result = ''
          sortedHeaders.each do |header|

            result << header << ';'

          end

          result.downcase

        end


      end

    end

  end

end
