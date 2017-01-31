module Stormpath
  module Resource
    module CustomDataHashMethods
      extend ActiveSupport::Concern

      included do
        def has_key?(key)
          materialize unless materialized?
          properties.key? key.to_s
        end

        alias_method :include?, :has_key?

        def has_value?(value)
          materialize unless materialized?
          properties.value? value
        end

        def store(key, value)
          materialize unless materialized?
          self[key] = value
        end

        def keys
          materialize unless materialized?
          properties.keys
        end

        def values
          materialize unless materialized?
          properties.values
        end
      end
    end
  end
end
