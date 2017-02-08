module Stormpath
  module Authentication
    class RegisteredServiceProviderAttempt < Stormpath::Resource::Base
      def set_attributes(options = {})
        options.compact!
        set_property(:assertion_consumer_service_url, options[:assertion_consumer_service_url])
        set_property(:entity_id, options[:entity_id])
        set_property(:name_id_format, options[:name_id_format]) if options.key?(:name_id_format)
        set_property(:name, options[:name])
        set_property(:description, options[:description])
        self
      end
    end
  end
end
