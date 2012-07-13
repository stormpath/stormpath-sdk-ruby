require "stormpath-sdk/resource/utils"

module Stormpath

  module Resource

    class Resource

      include Utils

      HREF_PROP_NAME = "href"

      def initialize dataStore, properties

        @dataStore = dataStore
        @readLock = Mutex.new
        @writeLock = Mutex.new
        @properties = Hash.new
        set_properties properties

      end

      def set_properties properties

        @writeLock.lock

        begin

          @dirty = false

          if (!properties.nil? and properties.is_a? Hash)
            @properties.replace properties
            href_only = @properties.size == 1 and @properties.has_key? HREF_PROP_NAME
            @materialized = !href_only

          else
            @materialized = false
          end

        ensure
          @writeLock.unlock
        end
      end

      def get_property name

        if (!HREF_PROP_NAME.eql? name)
          #not the href/id, must be a property that requires materialization:
          if (!is_new and !materialized)

            materialize
          end
        end

        read_property name
      end

      def get_property_names
        @readLock.lock

        begin
          @properties.keys
        ensure
          @readLock.unlock
        end

      end

      def get_href
        get_property HREF_PROP_NAME
      end

      attr_reader :properties

      protected

      attr_reader :dataStore, :materialized

      def get_resource_property key, clazz

        value = get_property key

        if (value.is_a? Hash)
          href = get_href_from_hash value
        end

        if (!href.nil?)
          @dataStore.instantiate clazz, value
        end
      end

      ##
      # Returns {@code true} if the resource doesn't yet have an assigned 'href' property, {@code false} otherwise.
      #
      # @return {@code true} if the resource doesn't yet have an assigned 'href' property, {@code false} otherwise.
      def is_new

        #we can't call get_href in here, otherwise we'll have an infinite loop:

        prop = read_property HREF_PROP_NAME

        if (prop.nil?)
          true

        else
          prop.respond_to? 'empty' and prop.empty?
        end

      end

      def set_property name, value

        @writeLock.lock

        begin
          if (value.nil?)

            removed = @properties.delete name

            if (!removed.nil?)
              @dirty = true
            end

          else
            @properties.store name, value
            @dirty = true
          end
        ensure
          @writeLock.unlock
        end

      end

      def materialize
        clazz = to_class_from_instance self

        @writeLock.lock

        begin

          resource = @dataStore.get_resource get_href, clazz
          @properties.replace resource.properties
          @materialized = true

        ensure

          @writeLock.unlock
        end
      end

      private

      def get_href_from_hash(props)

        if (!props.nil? and props.is_a? Hash)
          value = props[HREF_PROP_NAME]
        end

        value
      end

      def read_property name
        @readLock.lock

        begin
          @properties[name]
        ensure
          @readLock.unlock
        end

      end
    end
  end

end
