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
    class Request
      include Stormpath::Http::Utils

      attr_accessor :http_method, :href, :query_string, :http_headers, :body, :api_key

      def initialize(http_method, href, query_string, http_headers, body, api_key)
        splitted = href.split '?'

        @query_string = query_string || {}

        if splitted && splitted.length > 1
          @href = splitted[0]
          query_string_str = splitted[1]
          query_string_arr = query_string_str.split '&'
          query_string_arr.each do |pair|
            pair_arr = pair.split '='
            @query_string.store pair_arr[0], pair_arr[1]
          end
        else
          @href = href
        end

        @http_method = http_method.to_s.upcase
        @http_headers = http_headers
        @body = body
        @api_key = api_key

        @http_headers.store 'Content-Length', @body.bytesize if body
      end

      def resource_uri
        URI href
      end

      def to_s_query_string(canonical)
        result = ''

        unless @query_string.empty?
          Hash[@query_string.sort_by(&:to_s)].each do |key, value|
            enc_key = encode_url key, false, canonical
            enc_value = encode_url value, false, canonical

            result << '&' unless result.empty?
            result << camelize(enc_key) << '=' << enc_value
          end
        end

        result
      end

      def camelize(key)
        custom_data_params?(key) ? key : key.camelize(:lower)
      end

      def custom_data_params?(key)
        key.starts_with?('customData.')
      end
    end
  end
end
