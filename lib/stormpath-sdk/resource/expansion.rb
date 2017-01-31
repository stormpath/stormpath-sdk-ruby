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
  module Resource
    class Expansion
      attr_reader :query

      def initialize(*names)
        @query = {}
        @properties = {}

        names.each { |name| add_property name }
      end

      def add_property(name, options = {})
        @properties[name] = if options[:offset] || options[:limit]
                              pagination = []
                              pagination.push("offset:#{options[:offset]}") if options[:offset]
                              pagination.push("limit:#{options[:limit]}") if options[:limit]

                              "#{name}(#{pagination.join(',')})"
                            else
                              name
                            end
      end

      def to_query
        { expand: @properties.values.join(',') } if @properties.any?
      end
    end
  end
end
