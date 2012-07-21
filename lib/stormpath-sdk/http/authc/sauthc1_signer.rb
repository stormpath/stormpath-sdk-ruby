module Stormpath

  module Http

    module Authc

      class Sauthc1Signer

        include OpenSSL
        include UUIDTools
        include Stormpath::Util

        DEFAULT_ALGORITHM = "SHA256"
        HOST_HEADER = "Host"
        AUTHORIZATION_HEADER = "Authorization"
        STORMPATH_DATE_HEADER = "X-Stormpath-Date"
        ID_TERMINATOR = "sauthc1_request"
        ALGORITHM = "HMAC-SHA-256"
        AUTHENTICATION_SCHEME = "SAuthc1"
        SAUTHC1_ID = "sauthc1Id"
        SAUTHC1_SIGNED_HEADERS = "sauthc1SignedHeaders"
        SAUTHC1_SIGNATURE = "sauthc1Signature"
        DATE_FORMAT = "%Y%m%d"
        TIMESTAMP_FORMAT = "%Y%m%dT%H%M%SZ"
        NL = "\\n"

        def sign_request request, apiKey

          time = Time.now
          timestamp = time.utc.strftime TIMESTAMP_FORMAT
          dateStamp = time.utc.strftime DATE_FORMAT

          nonce = UUID.random_create.to_s

          uri = request.resource_uri

          # SAuthc1 requires that we sign the Host header so we
          # have to have it in the request by the time we sign.
          hostHeader = uri.host
          if !RequestUtils.default_port?(uri)

            hostHeader << ":" << uri.port.to_s
          end

          request.httpHeaders.store HOST_HEADER, hostHeader

          request.httpHeaders.store STORMPATH_DATE_HEADER, timestamp

          method = request.httpMethod
          canonicalResourcePath = canonicalize_resource_path uri.path
          canonicalQueryString = canonicalize_query_string request
          canonicalHeadersString = canonicalize_headers request
          signedHeadersString = get_signed_headers request
          requestPayloadHashHex = to_hex(hash(get_request_payload(request)))

          canonicalRequest = method + NL +
              canonicalResourcePath + NL +
              canonicalQueryString + NL +
              canonicalHeadersString + NL +
              signedHeadersString + NL +
              requestPayloadHashHex

          id = apiKey.id + "/" + dateStamp + "/" + nonce + "/" + ID_TERMINATOR

          canonicalRequestHashHex = to_hex(hash(canonicalRequest))

          stringToSign = ALGORITHM + NL +
              timestamp + NL +
              id + NL +
              canonicalRequestHashHex

          # SAuthc1 uses a series of derived keys, formed by hashing different pieces of data
          kSecret = to_utf8 AUTHENTICATION_SCHEME + apiKey.secret
          kDate = sign dateStamp, kSecret, DEFAULT_ALGORITHM
          kNonce = sign nonce, kDate, DEFAULT_ALGORITHM
          kSigning = sign ID_TERMINATOR, kNonce, DEFAULT_ALGORITHM

          signature = sign to_utf8(stringToSign), kSigning, DEFAULT_ALGORITHM
          signatureHex = to_hex signature

          authorizationHeader = AUTHENTICATION_SCHEME + " " +
              create_name_value_pair(SAUTHC1_ID, id) + ", " +
              create_name_value_pair(SAUTHC1_SIGNED_HEADERS, signedHeadersString) + ", " +
              create_name_value_pair(SAUTHC1_SIGNATURE, signatureHex);

          request.httpHeaders.store AUTHORIZATION_HEADER, authorizationHeader

        end


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
          Digest.digest DEFAULT_ALGORITHM, to_utf8(text)
        end

        def sign data, key, algorithm

          data = to_utf8 data

          digest = Digest::Digest.new(algorithm)

          HMAC.digest(digest, key, data)

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
          result = name + '=' + value
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

            result << header.downcase << ':' << request.httpHeaders[header]

            result << NL
          end

          result

        end

        def get_signed_headers request

          sortedHeaders = request.httpHeaders.keys.sort!

          result = ''
          sortedHeaders.each do |header|

            if !result.empty?
              result << ';' << header
            else
              result << header
            end


          end

          result.downcase

        end


      end

    end

  end

end
