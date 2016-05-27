#
# Copyright 2016 Stormpath, Inc.
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
    class StatusPropertyDefiner
      ENABLED = 'ENABLED'
      DISABLED = 'DISABLED'

      DEFAULT_STATUS_LIST = { ENABLED => ENABLED, DISABLED => DISABLED }

      UNVERIFIED = 'UNVERIFIED'
      LOCKED = 'LOCKED'

      ACCOUNT_STATUS_LIST = DEFAULT_STATUS_LIST.merge(UNVERIFIED => UNVERIFIED, LOCKED => LOCKED)

      attr_reader :klass, :property_name, :status_list

      def initialize(klass, property_name, status_list)
        @klass = klass
        @property_name = property_name
        @status_list = status_list
      end

      def call
        define_accessor(property_name, status_hash)
      end

      private

      def define_accessor(property_name, status_hash)
        define_getter(property_name, status_hash)
        define_setter(property_name, status_hash)
      end

      def define_getter(property_name, status_hash)
        klass.class_eval do
          define_method property_name do
            value = get_property property_name
            value.upcase! if value
            value
          end
        end
      end

      def define_setter(property_name, status_hash)
        klass.class_eval do
          define_method "#{property_name}=" do |value|
            if status_hash.has_key? value
              set_property property_name, status_hash[value]
            end
          end
        end
      end

      def status_hash
        case status_list
        when :default
          DEFAULT_STATUS_LIST
        when :account
          ACCOUNT_STATUS_LIST
        else
          raise ArgumentError, "unknown status #{status_list}"
        end
      end
    end
  end
end
