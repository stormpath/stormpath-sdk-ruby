module Stormpath
  module Util
    class BodyExtractor
      include Stormpath::Util::Assert

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def self.for(resource)
        new(resource)
      end

      def call
        return if resource.nil?
        if resource_is_form_data?
          parsed_resource_form_request
        else
          parsed_resource_hash_request
        end
      end

      private

      def resource_is_form_data?
        resource.try(:form_data?)
      end

      def parsed_resource_form_request
        URI.encode_www_form(resource.form_properties.to_a)
      end

      def parsed_resource_hash_request
        MultiJson.dump(hash_properties)
      end

      def hash_properties
        {}.tap do |properties|
          resource.get_dirty_property_names.each do |name|
            property = resource.get_property(
              name, ignore_camelcasing: resource_is_custom_data?(resource, name)
            )

            # Special use cases are with
            # Custom Data, Provider and ProviderData, Phone, Agent config property accessor
            # Their hashes should not be simplified
            if property.is_a?(Hash) && !resource_nested_submittable(resource, name) && name != 'items' && name != 'phone' && name != 'config'
              property = to_simple_reference(name, property)
            end

            if (name == 'items' && resource.try(:mapping_rule?)) ||
               (name == 'config' && resource_is_agent_config?(resource))
              if property.is_a?(Array)
                property = property.map do |item|
                  item.transform_keys { |key| camel_case(key) }
                end
              elsif property.is_a?(Hash)
                property = property.deep_transform_keys { |key| camel_case(key) }
              end
            end

            properties.store(name, property)
          end
        end
      end

      def camel_case(key)
        key.to_s.camelize(:lower).to_sym
      end

      def to_simple_reference(property_name, hash)
        assert_true(
          hash.key?(Stormpath::Resource::Base::HREF_PROP_NAME),
          "Nested resource '#{property_name}' must have an 'href' property."
        )

        href = hash[Stormpath::Resource::Base::HREF_PROP_NAME]

        { Stormpath::Resource::Base::HREF_PROP_NAME => href }
      end

      def resource_nested_submittable(resource, name)
        ['provider', 'providerData', 'accountStore'].include?(name) ||
          resource_is_custom_data?(resource, name) ||
          resource_is_application_web_config(resource, name)
      end

      def resource_is_custom_data?(resource, name)
        resource.is_a?(Stormpath::Resource::CustomData) || name == 'customData'
      end

      def resource_is_application_web_config(resource, name)
        resource.is_a?(Stormpath::Resource::ApplicationWebConfig) &&
          Stormpath::Resource::ApplicationWebConfig::ENDPOINTS.include?(name.underscore.to_sym)
      end

      def resource_is_agent_config?(resource)
        resource.is_a?(Stormpath::Resource::Agent)
      end

      def resource_is_mapping_rules?(resource)
        resource.is_a?(Stormpath::Resource::AttributeStatementMappingRules) ||
          resource.is_a?(Stormpath::Resource::UserInfoMappingRules)
      end
    end
  end
end
