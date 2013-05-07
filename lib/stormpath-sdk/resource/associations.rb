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

          define_method(name) do
            Stormpath::Resource::Collection.new(get_resource_href_property(property_name), item_class, client)
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
