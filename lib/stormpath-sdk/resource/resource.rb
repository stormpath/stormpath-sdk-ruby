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

    class Resource

      include Utils

      HREF_PROP_NAME = "href"

      def initialize data_store, properties = {}

        @data_store = data_store
        @read_lock = Mutex.new
        @write_lock = Mutex.new
        @properties = Hash.new
        @dirty_properties = Hash.new
        set_properties properties

      end

      def set_properties properties

        @write_lock.lock

        begin

          @properties.clear
          @dirty_properties.clear
          @dirty = false

          if !properties.nil? and properties.is_a? Hash
            @properties.replace properties

            # Don't consider this resource materialized if it is only a reference.  A reference is any object that
            # has only one 'href' property.
            href_only = @properties.size == 1 and @properties.has_key? HREF_PROP_NAME
            @materialized = !href_only

          else
            @materialized = false
          end

        ensure
          @write_lock.unlock
        end
      end

      def get_property name

        if !HREF_PROP_NAME.eql? name
          #not the href/id, must be a property that requires materialization:
          if !is_new and !materialized

            # only materialize if the property hasn't been set previously (no need to execute a server
            # request since we have the most recent value already):
            present = false
            @read_lock.lock

            begin

              present = @dirty_properties.has_key? name

            ensure

              @read_lock.unlock

            end

            if !present
              # exhausted present properties - we require a server call:
              materialize
            end

          end

        end

        read_property name
      end

      def get_property_names
        @read_lock.lock

        begin
          @properties.keys
        ensure
          @read_lock.unlock
        end

      end

      def get_href
        get_property HREF_PROP_NAME
      end

      def inspect

        @read_lock.lock

        str = ''

        begin

          counter = 2
          @properties.each do |key, value|

            if str.empty?

              str = '#<' + class_name_with_id + ' @properties={'

            else

              if printable_property? key

                str << "\"#{key}\"=>"

                if value.kind_of? Hash and value.has_key? HREF_PROP_NAME

                  str << '{"' << HREF_PROP_NAME + '"=>"' + value[HREF_PROP_NAME] + '"}'

                else

                  str << "\"#{value}\""

                end

                if counter < @properties.length

                  str << ', '

                end

              end

              counter+= 1

            end

          end

        ensure

          @read_lock.unlock

        end

        if !str.empty?
          str << '}>'
        end

        str

      end

      def to_s
        '#<' + class_name_with_id + '>'
      end

      def to_yaml

        yaml = '--- !ruby/object:' << self.class.name << "\n"

        @read_lock.lock

        begin

          first_property = true
          @properties.each do |key, value|

            if printable_property? key

              if first_property

                yaml << " properties\n "

              end

              yaml << ' ' << key << ': ' << value << "\n"

              first_property = false

            end

          end

        ensure

          @read_lock.unlock

        end

        yaml << "\n"

      end

      protected

      attr_reader :data_store, :materialized

      def get_resource_property key, clazz

        value = get_property key

        if value.is_a? Hash
          href = get_href_from_hash value
        end

        if !href.nil?
          @data_store.instantiate clazz, value
        end
      end

      ##
      # Returns {@code true} if the resource doesn't yet have an assigned 'href' property, {@code false} otherwise.
      #
      # @return {@code true} if the resource doesn't yet have an assigned 'href' property, {@code false} otherwise.
      def is_new

        #we can't call get_href in here, otherwise we'll have an infinite loop:

        prop = read_property HREF_PROP_NAME

        if prop.nil?
          true

        else
          prop.respond_to? 'empty' and prop.empty?
        end

      end

      def set_property name, value

        @write_lock.lock

        begin
          @properties.store name, value
          @dirty_properties.store name, value
          @dirty = true
        ensure
          @write_lock.unlock
        end

      end

      def materialize
        clazz = to_class_from_instance self

        @write_lock.lock

        begin

          resource = @data_store.get_resource get_href, clazz
          @properties.replace resource.properties

          #retain dirty properties:
          @properties.merge! @dirty_properties

          @materialized = true

        ensure

          @write_lock.unlock
        end

      end

      def properties
        @properties
      end

      ##
      # Returns {@code true} if the internal property is safe to print in to_s or inspect, {@code false} otherwise.
      #
      # @param property_name The name of the property to check for safe printing
      # @return {@code true} if the internal property is safe to print in to_s, {@code false} otherwise.
      def printable_property? property_name

        return true

      end

      private

      def get_href_from_hash(props)

        if !props.nil? and props.is_a? Hash
          value = props[HREF_PROP_NAME]
        end

        value
      end

      def read_property name
        @read_lock.lock

        begin
          @properties[name]
        ensure
          @read_lock.unlock
        end

      end

      def class_name_with_id
        self.class.name + ':0x' + ('%x' % (self.object_id << 1)).to_s
      end
    end
  end

end
