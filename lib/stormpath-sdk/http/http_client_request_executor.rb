#
# Copyright 2013 Stormpath, Inc.
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
    class HttpClientRequestExecutor
      include Stormpath::Http::Authc
      include Stormpath::Util::Assert

      def initialize(options = {})
        @signer = Sauthc1Signer.new
        @http_client = HTTPClient.new options[:proxy]
      end

      def execute_request(request, api_key, redirects_limit = 10)
        assert_not_nil request, "Request argument cannot be null."

        @redirect_response = nil

        @signer.sign_request request, api_key

        domain = if request.query_string.present?
                   [request.href, request.to_s_query_string(true)].join '?'
                 else
                   request.href
                 end

        method = @http_client.method(request.http_method.downcase)

        response = method.call domain, request.body, request.http_headers

        if response.redirect? and redirects_limit > 0
          request.href = response.http_header['location'][0]
          redirects_limit -= 1
          @redirect_response = execute_request request, api_key, redirects_limit
          return @redirect_response
        end

        Response.new response.http_header.status_code,
                     response.http_header.body_type,
                     response.content,
                     response.http_header.body_size
      end
    end
  end
end

