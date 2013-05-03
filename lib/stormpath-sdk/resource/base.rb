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
class Stormpath::Resource::Base
  include Stormpath::Resource::Utils

  HREF_PROP_NAME = "href"

  attr_reader :client, :properties

  class << self
    def prop_reader(*args)
      args.each do |name|
        property_name = name.to_s.camelize :lower

        define_method(name) do
          get_property property_name
        end
      end
    end

    def prop_writer(*args)
      args.each do |name|
        property_name = name.to_s.camelize :lower

        define_method("#{name.to_s}=") do |value|
          set_property property_name, value
        end
      end
    end

    def prop_accessor(*args)
      args.each do |name|
        prop_reader name
        prop_writer name
      end
    end

    def resource_prop_reader(*args)
      args.each do |name|
        resource_class = "Stormpath::Resource::#{name.to_s.camelize}".constantize
        property_name = name.to_s.camelize :lower

        define_method(name) do
          get_resource_property property_name, resource_class
        end
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

  def initialize properties_or_url, client=nil
    properties = case properties_or_url
                 when String
                   { HREF_PROP_NAME => properties_or_url }
                 when Hash
                   properties_or_url
                 else
                   {}
                 end

    @client = client
    @read_lock = Mutex.new
    @write_lock = Mutex.new
    @properties = Hash.new
    @dirty_properties = Hash.new
    set_properties properties
  end

  def new?
    prop = read_property HREF_PROP_NAME

    if prop.nil?
      true
    else
      prop.respond_to? 'empty' and prop.empty?
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

  def set_properties properties
    @write_lock.lock

    begin
      @properties.clear
      @dirty_properties.clear
      @dirty = false

      if !properties.nil? and properties.is_a? Hash
        properties.map do |key, value|
          property_name = key.to_s.camelize :lower
          @properties.store property_name, value
        end

        # Don't consider this resource materialized if it is only a reference.  A reference is any object that
        # has only one 'href' property.
        href_only = (@properties.size == 1 and @properties.has_key? HREF_PROP_NAME)
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
      unless new? or materialized?

        # only materialize if the property hasn't been set previously (no need to execute a server
        # request since we have the most recent value already):
        present = false

        @read_lock.lock
        begin
          present = @dirty_properties.has_key? name
        ensure
          @read_lock.unlock
        end

        unless present
          # exhausted present properties - we require a server call:
          materialize
        end
      end
    end

    read_property name
  end

  def get_resource_property key, clazz
    value = get_property key

    if value.is_a? Hash
      href = get_href_from_hash value
    end

    unless href.nil?
      data_store.instantiate clazz, value
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

  protected

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
      resource = data_store.get_resource href, clazz
      @properties.replace resource.properties

      #retain dirty properties:
      @properties.merge! @dirty_properties

      @materialized = true
    ensure
      @write_lock.unlock
    end
  end

  def printable_property? property_name
    !self.class.non_printable_properties.include? property_name
  end

  private

  def get_href_from_hash(props)
    if !props.nil? and props.is_a? Hash
      props[HREF_PROP_NAME]
    end
  end

  def read_property name
    @read_lock.lock

    begin
      @properties[name]
    ensure
      @read_lock.unlock
    end
  end
end
