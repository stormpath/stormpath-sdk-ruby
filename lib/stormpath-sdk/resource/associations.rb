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
    module Associations
      extend ActiveSupport::Concern

      module ClassMethods
        def resource_prop_reader(name, options = {})
          options[:class_name] ||= name
          resource_class = "Stormpath::Resource::#{options[:class_name].to_s.camelize}".constantize
          property_name = name.to_s.camelize :lower
          define_method(name) do
            get_resource_property property_name, resource_class
          end
        end

        alias has_one resource_prop_reader
        alias belongs_to resource_prop_reader

        def has_many(name, options = {}, &block)
          options[:class_name] ||= name.to_s.singularize
          item_class = "Stormpath::Resource::#{options[:class_name].to_s.camelize}".constantize
          property_name = name.to_s.camelize :lower
          can = Array.wrap(options[:can]) || []

          define_method(name) do
            href = options[:href] || get_resource_href_property(property_name)
            collection_href = "#{tenant.send(name).href}" if options[:delegate]

            Stormpath::Resource::Collection.new(href, item_class, client,
                                                collection_href: collection_href).tap do |collection|

              collection.class_eval do
                if can.include?(:create)
                  def create(properties_or_resource, options = {})
                    resource = case properties_or_resource
                               when Stormpath::Resource::Base
                                 properties_or_resource
                               else
                                 item_class.new(properties_or_resource, client)
                               end
                    data_store.create(href, resource, item_class, options)
                  end
                end # can.include? :create

                if can.include? :get
                  def get(id_or_href, expansion = nil)
                    item_href = if id_or_href.index '/'
                                  id_or_href
                                else
                                  "#{href}/#{id_or_href}"
                                end
                    data_store.get_resource(item_href, item_class, (expansion ? expansion.to_query : nil))
                  end
                end # can.include? :get
              end # collection.class_eval do

              collection.class_eval(&block) if block
            end # Stormpath::Resource::Collection.new
          end # define_method(name)
        end # def has_many
      end # module Class Methods

      included do
        private

          def get_resource_property(key, clazz)
            value = get_property key

            return nil if value.nil? && (clazz != Stormpath::Resource::CustomData)

            resource_href = get_href_from_hash value if value.is_a? Hash

            key_name = "@_#{key.underscore}"

            if instance_variable_get(key_name).nil?
              if resource_href
                instance_variable_set(key_name, data_store.instantiate(clazz, value))
              else
                instance_variable_set(key_name, clazz.new(value))
              end
            end
            instance_variable_get(key_name)
          end

          def get_resource_href_property(key)
            value = get_property key

            get_href_from_hash value if value.is_a? Hash
          end
      end # included do
    end # Associations
  end # Resource
end # Stormpath
