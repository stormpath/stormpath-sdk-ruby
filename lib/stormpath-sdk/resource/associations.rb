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

        def has_many(name, options={})
          item_class = options[:class] || "Stormpath::Resource::#{name.to_s.singularize.camelize}".constantize
          property_name = name.to_s.camelize :lower
          can = Array.wrap(options[:can]) || []

          define_method(name) do
            href = options[:href] || get_resource_href_property(property_name)
            Stormpath::Resource::Collection.new(href, item_class, client).tap do |collection|
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
                  def get(id_or_href)
                    item_href = if id_or_href.index '/'
                                  id_or_href
                                else
                                  "#{href}/#{id_or_href}"
                                end
                    data_store.get_resource item_href, item_class
                  end
                end
              end
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
