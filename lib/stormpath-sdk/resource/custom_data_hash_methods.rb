module Stormpath::Resource::CustomDataHashMethods
  extend ActiveSupport::Concern

  included do
    DELEGATED_METHODS = [:has_key?, :has_value?, :include?, :store, :keys, :values]

    def has_key?(key)
      materialize unless materialized?
      properties.has_key? key.to_s.camelize(:lower)
    end

    alias_method :include?, :has_key?

    def has_value?(value)
      materialize unless materialized?
      properties.has_value? value
    end

    def store(key, value)
      materialize unless  materialized?
      self[key] = value
    end

    def keys
      materialize unless materialized?
      properties.keys.map {|key| key.to_s.underscore}
    end

    def values
      materialize unless materialized?
      properties.values
    end
  end

end