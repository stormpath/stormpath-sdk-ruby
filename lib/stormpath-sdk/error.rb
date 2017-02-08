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
  class Error < RuntimeError
    attr_reader :status, :code, :developer_message, :more_info, :request_id

    def initialize(error = NilError.new)
      super error.message
      @status = error.status
      @code = error.code
      @developer_message = error.developer_message
      @more_info = error.more_info
      @request_id = error.request_id
    end

    private

    class NilError
      def message
        ''
      end

      def status
        -1
      end

      def code
        -1
      end

      def developer_message; end

      def more_info; end

      def request_id; end
    end
  end
end
