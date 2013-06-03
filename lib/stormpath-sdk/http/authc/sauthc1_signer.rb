#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Stormpath

  module Http

    module Authc

      class Sauthc1Signer

        include OpenSSL
        include UUIDTools
        include Stormpath::Http::Utils

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
        #noinspection RubyConstantNamingConvention
        NL = "\n"

        def initialize(uuid_generator=UUID.method(:random_create))
          @uuid_generator = uuid_generator
        end

        def sign_request request, api_key

          time = Time.now
          time_stamp = time.utc.strftime TIMESTAMP_FORMAT
          date_stamp = time.utc.strftime DATE_FORMAT

          nonce = @uuid_generator.call.to_s

          uri = request.resource_uri

          # SAuthc1 requires that we sign the Host header so we
          # have to have it in the request by the time we sign.
          host_header = uri.host
          if !default_port?(uri)

            host_header << ":" << uri.port.to_s
          end

          request.http_headers.store HOST_HEADER, host_header

          request.http_headers.store STORMPATH_DATE_HEADER, time_stamp

          method = request.http_method
          canonical_resource_path = canonicalize_resource_path uri.path
          canonical_query_string = canonicalize_query_string request
          canonical_headers_string = canonicalize_headers request
          signed_headers_string = get_signed_headers request
          request_payload_hash_hex = to_hex(hash_text(get_request_payload(request)))

          canonical_request = method + NL +
              canonical_resource_path + NL +
              canonical_query_string + NL +
              canonical_headers_string + NL +
              signed_headers_string + NL +
              request_payload_hash_hex

          id = api_key.id + "/" + date_stamp + "/" + nonce + "/" + ID_TERMINATOR

          canonical_request_hash_hex = to_hex(hash_text(canonical_request))

          string_to_sign = ALGORITHM + NL +
              time_stamp + NL +
              id + NL +
              canonical_request_hash_hex

          # SAuthc1 uses a series of derived keys, formed by hashing different pieces of data
          k_secret = to_utf8 AUTHENTICATION_SCHEME + api_key.secret
          k_date = sign date_stamp, k_secret, DEFAULT_ALGORITHM
          k_nonce = sign nonce, k_date, DEFAULT_ALGORITHM
          k_signing = sign ID_TERMINATOR, k_nonce, DEFAULT_ALGORITHM

          signature = sign to_utf8(string_to_sign), k_signing, DEFAULT_ALGORITHM
          signature_hex = to_hex signature

          authorization_header = AUTHENTICATION_SCHEME + " " +
              create_name_value_pair(SAUTHC1_ID, id) + ", " +
              create_name_value_pair(SAUTHC1_SIGNED_HEADERS, signed_headers_string) + ", " +
              create_name_value_pair(SAUTHC1_SIGNATURE, signature_hex)

          request.http_headers.store AUTHORIZATION_HEADER, authorization_header

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

        protected

        def canonicalize_query_string request
          request.to_s_query_string true
        end

        def hash_text text
          Digest.digest DEFAULT_ALGORITHM, to_utf8(text)
        end

        def sign data, key, algorithm

          digest_data = to_utf8 data

          digest = Digest::Digest.new(algorithm)

          HMAC.digest(digest, key, digest_data)

        end

        def to_utf8 str
          #we ask for multi line UTF-8 text
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

        private

        def create_name_value_pair name, value
          name + '=' + value
        end

        def canonicalize_resource_path resource_path

          if resource_path.nil? or resource_path.empty?
            '/'
          else
            encode_url resource_path, true, true
          end
        end


        def canonicalize_headers request

          sorted_headers = request.http_headers.keys.sort!

          result = ''

          sorted_headers.each do |header|

            result << header.downcase << ':' << request.http_headers[header].to_s

            result << NL
          end

          result

        end

        def get_signed_headers request

          sorted_headers = request.http_headers.keys.sort!

          result = ''
          sorted_headers.each do |header|

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
