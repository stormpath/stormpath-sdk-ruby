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

  module Authentication

    class UsernamePasswordRequest

      attr_reader :host

      def initialize username, password, host
        @username = username
        @password = (password != nil and password.length > 0) ? password.chars.to_a : "".chars.to_a
        @host = host
      end

      def get_principals
        @username
      end

      def get_credentials
        @password
      end

      ##
      # Clears out (nulls) the username, password, and host.  The password bytes are explicitly set to
      # <tt>0x00</tt> to eliminate the possibility of memory access at a later time.
      def clear
        @username = nil
        @host = nil

        @password.each { |pass_char|

          pass_char = 0x00
        }

        @password = nil
      end

    end

  end

end

