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
    class Base
      include Stormpath::Resource::Utils
      include Stormpath::Resource::Associations

      HREF_PROP_NAME = 'href'.freeze
      DEFAULT_SERVER_HOST = Stormpath::DataStore::DEFAULT_SERVER_HOST
      attr_reader :client, :properties, :dirty_properties

      class << self
        def prop_reader(*args)
          args.each do |name|
            define_method(name) do
              get_property name
            end
          end
        end

        def prop_writer(*args)
          args.each do |name|
            define_method("#{name}=") do |value|
              set_property name, value
            end
          end
        end

        def prop_accessor(*args)
          args.each do |name|
            prop_reader name
            prop_writer name
          end
        end

        def prop_non_printable(*args)
          @non_printable_properties ||= []
          args.each do |name|
            property_name = name.to_s.camelize :lower
            @non_printable_properties << property_name
          end
        end

        def non_printable_properties
          @non_printable_properties ||= []
          Array.new @non_printable_properties
        end
      end

      def initialize(properties_or_url, client = nil, query = nil)
        properties = case properties_or_url
                     when String
                       { HREF_PROP_NAME => properties_or_url }
                     when Hash
                       properties_or_url
                     else
                       {}
                     end

        @client = client
        @query = query
        @read_lock = Mutex.new
        @write_lock = Mutex.new
        @properties = {}
        @dirty_properties = {}
        @deleted_properties = []
        set_properties properties
      end

      def new?
        prop = read_property HREF_PROP_NAME

        if prop.nil?
          true
        else
          prop.respond_to?('empty') && prop.empty?
        end
      end

      def href
        get_property HREF_PROP_NAME
      end

      def get_property_names
        @read_lock.lock

        begin
          @properties.keys
        ensure
          @read_lock.unlock
        end
      end

      def get_dirty_property_names
        @read_lock.lock

        begin
          @dirty_properties.keys
        ensure
          @read_lock.unlock
        end
      end

      def set_properties(properties)
        @write_lock.lock

        begin
          @properties.clear
          @dirty_properties.clear
          @dirty = false

          if properties
            @properties = deep_sanitize properties
            @dirty_properties = @properties if new?
            # Don't consider this resource materialized if it is only a reference.  A reference is any object that
            # has only one 'href' property.
            href_only = ((@properties.size == 1) && @properties.key?(HREF_PROP_NAME))
            @materialized = !href_only
          else
            @materialized = false
          end

        ensure
          @write_lock.unlock
        end
      end

      def get_property(name, options = {})
        property_name = name.to_s

        unless options[:ignore_camelcasing] == true
          property_name = property_name.camelize(:lower)
        end

        if HREF_PROP_NAME != property_name
          # not the href/id, must be a property that requires materialization:
          unless new? || materialized?

            # only materialize if the property hasn't been set previously (no need to execute a server
            # request since we have the most recent value already):
            present = false

            @read_lock.lock
            begin
              present = @dirty_properties.key? property_name
            ensure
              @read_lock.unlock
            end

            unless present
              # exhausted present properties - we require a server call:
              materialize
            end
          end
        end

        read_property property_name
      end

      def set_property(name, value, options = {})
        property_name = name.to_s

        unless options[:ignore_camelcasing] == true
          property_name = property_name.camelize(:lower)
        end

        @write_lock.lock

        begin
          @properties.store property_name, value
          @dirty_properties.store property_name, value
          @dirty = true
        ensure
          @write_lock.unlock
        end
      end

      def ==(other)
        if other.is_a?(self.class)
          href == other.href
        else
          super
        end
      end

      private

      def data_store
        client.data_store
      end

      def materialized?
        @materialized
      end

      def materialize
        clazz = self.class

        @write_lock.lock

        begin
          resource = data_store.get_resource href, clazz, @query
          @properties.replace resource.properties

          # retain dirty properties:
          @properties.merge! @dirty_properties

          @materialized = true
        ensure
          @write_lock.unlock
        end
      end

      def printable_property?(property_name)
        !self.class.non_printable_properties.include? property_name
      end

      def get_href_from_hash(props)
        props[HREF_PROP_NAME] if props && props.is_a?(Hash)
      end

      def read_property(name)
        @read_lock.lock

        begin
          @properties[name]
        ensure
          @read_lock.unlock
        end
      end

      def sanitize(properties)
        {}.tap do |sanitized_properties|
          properties.map do |key, value|
            property_name = key.to_s.camelize :lower
            sanitized_properties[property_name] =
              if (value.is_a?(Hash) || value.is_a?(Stormpath::Resource::Base)) && (property_name != 'customData')
                deep_sanitize value
              else
                value
              end
          end
        end
      end

      def deep_sanitize(hash_or_resource)
        case hash_or_resource
        when Stormpath::Resource::Base
          deep_sanitize hash_or_resource.properties
        when Hash
          sanitize hash_or_resource
        end
      end
    end
  end
end
