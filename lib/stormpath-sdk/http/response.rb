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
    class Response

      attr_reader :http_status, :headers, :body
      attr_writer :headers

      def initialize http_status, content_type, body, content_length
        @http_status = http_status
        @headers = HTTP::Message::Headers.new
        @body = body
        @headers.content_type = content_type
        @headers.body_size = content_length
      end

      def client_error?
        http_status >= 400 and http_status < 500
      end

      def server_error?
        http_status >= 500 and http_status < 600
      end

      def error?
        client_error? or server_error?
      end

    end
  end
end
