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
    module Utils
      include ActiveSupport::Inflector
      include Stormpath::Util::Assert

      def inspect
        ''.tap do |str|
          str << %(#<#{class_name_with_id} @properties={)
          @read_lock.lock
          begin
            str << properties.map do |key, value|
              next unless printable_property? key
              if value.is_a?(Hash) && value.key?(Stormpath::Resource::Base::HREF_PROP_NAME)
                value = %({ "#{Stormpath::Resource::Base::HREF_PROP_NAME}" => "#{value[Stormpath::Resource::Base::HREF_PROP_NAME]}" })
              end
              %("#{key} => #{value}")
            end.compact.join(',')
          ensure
            @read_lock.unlock
          end
          str << '}>'
        end
      end

      def to_s
        "#<#{class_name_with_id}>"
      end

      def to_yaml
        "--- !ruby/object: #{self.class.name}\n".tap do |yaml|
          @read_lock.lock

          begin
            properties_yaml = properties.each do |key, value|
              " #{key}: #{value} \n" if printable_property? key
            end.compact.join("\n")
            unless properties_yaml.empty?
              yaml << " properties\n "
              yaml << properties_yaml
            end
          ensure
            @read_lock.unlock
          end
        end
      end

      def class_name_with_id
        object_id_hex = '%x' % (object_id << 1)
        "#{self.class.name}:0x#{object_id_hex}"
      end
    end
  end
end
