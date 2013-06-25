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

        def resource_prop_reader(*args)
          args.each do |name|
            resource_class = "Stormpath::Resource::#{name.to_s.camelize}".constantize
            property_name = name.to_s.camelize :lower

            define_method(name) do
              get_resource_property property_name, resource_class
            end
          end
        end

        alias_method :has_one, :resource_prop_reader
        alias_method :belongs_to, :resource_prop_reader

        def has_many(name, options={}, &block)
          item_class = options[:class] || "Stormpath::Resource::#{name.to_s.singularize.camelize}".constantize
          property_name = name.to_s.camelize :lower
          can = Array.wrap(options[:can]) || []

          define_method(name) do
            href = options[:href] || get_resource_href_property(property_name)
            collection_href = if options[:delegate]
              "#{tenant.send(name.to_s).href}"
            end

            Stormpath::Resource::Collection.new(href, item_class, client,
              collection_href: collection_href).tap do |collection|

              collection.class_eval do
                if can.include? :create
                  def create(properties_or_resource)
                    resource = case properties_or_resource
                      when Stormpath::Resource::Base
                        properties_or_resource
                      else
                        item_class.new properties_or_resource, client
                      end
                    data_store.create href, resource, item_class
                  end
                end

                if can.include? :get
                  def get(id_or_href, expansion=nil)
                    item_href = if id_or_href.index '/'
                      id_or_href
                    else
                      "#{href}/#{id_or_href}"
                    end
                    data_store.get_resource item_href, item_class, (expansion ? expansion.to_query : nil)
                  end
                end
              end

              collection.class_eval(&block) if block
            end
          end
        end

      end

      included do

        private

          def get_resource_property(key, clazz)
            value = get_property key

            if value.is_a? Hash
              href = get_href_from_hash value
            end

            unless href.nil?
              data_store.instantiate clazz, value
            end
          end

          def get_resource_href_property(key)
            value = get_property key

            if value.is_a? Hash
              get_href_from_hash value
            else
              nil
            end
          end

      end
    end
  end
end
