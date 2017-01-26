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
  module Util
    module Assert

      def assert_not_nil(object, message)
        raise(ArgumentError, message, caller) if object.nil?
      end

      def assert_kind_of(clazz, object, message)
        raise(ArgumentError, message, caller) unless object.kind_of? clazz
      end

      def assert_true(arg, message)
        raise(ArgumentError, message, caller) unless arg
      end

      def assert_false(arg, message)
        raise(ArgumentError, message, caller) if arg
      end

      def assert_not_blank(object, message)
        raise(ArgumentError, message, caller) if object.blank?
      end
    end
  end
end
