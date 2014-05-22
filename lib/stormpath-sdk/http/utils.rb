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
    module Utils

      def default_port?(uri)
        scheme = uri.scheme.downcase
        port = uri.port
        port <= 0 || (port == 80 && scheme.eql?("http")) || (port == 443 && scheme.eql?("https"))
      end

      def encode_url(value, path, canonical)
        if path
          return URI.escape(value.to_s)
        else
          CGI.escape(value.to_s).tap do |encoded|
            str_map = {'+' => '%20', '%7E' => '~' }

            str_map.each do |key, str_value|
              if encoded.include? key
                encoded.gsub!(key, str_value)
              end
            end

          end
        end
        # URI.escape(value.to_s).tap do |encoded|
        #   if canonical
        #     str_map = {'+' => '%20', '*' => '%2A', '@' => '%40', '%7E' => '~' }
        #     # encoded['%7E'] = '~'  --> yes, this is reversed (compared to the other three) intentionally

        #     str_map.each do |key, str_value|
        #       if encoded.include? key
        #         encoded[key] = str_value
        #       end
        #     end

        #     if path
        #       str = '%2F'
        #       if encoded.include? str
        #         encoded[str] = '/'
        #       end
        #     end
        #   end
        # end
      end

    end
  end
end
