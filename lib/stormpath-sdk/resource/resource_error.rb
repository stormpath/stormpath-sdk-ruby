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

  module Resource

    class ResourceError < RuntimeError

      def initialize error
        super !error.nil? ? error.get_message : ''
        @error = error
      end

      def get_status
        !@error.nil? ? @error.get_status : -1
      end

      def get_code
        !@error.nil? ? @error.get_code : -1
      end

      def get_developer_message
        !@error.nil? ? @error.get_developer_message : nil
      end

      def get_more_info
        !@error.nil? ? @error.get_more_info : nil
      end

    end

  end
end

