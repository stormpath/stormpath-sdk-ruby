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

      include Stormpath::Util

      attr_accessor :http_method, :href, :query_string, :http_headers, :body

      def initialize(http_method, href, query_string, http_headers, body)

        splitted = href.split '?'

        if query_string.nil?
          @query_string = Hash.new
        else
          @query_string = query_string
        end

        if !splitted.nil? and splitted.length > 1
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

        @http_method = http_method.upcase
        @http_headers = http_headers
        @body = body

        if !body.nil?
          @http_headers.store 'Content-Length', @body.length
        end

      end

      def resource_uri
        URI href
      end

      def to_s_query_string canonical

        result = ''

        if !@query_string.empty?

          @query_string.each do |key, value|

            enc_key = RequestUtils.encode_url key, false, canonical
            enc_value = RequestUtils.encode_url value, false, canonical

            if !result.empty?
              result << '&'
            end

            result << enc_key << '='<< enc_value

          end

        end

        result
      end

    end

  end

end
