module Stormpath
  module Authentication
    class RegisterServiceProvider < Stormpath::Resource::Base
      attr_reader :client, :identity_provider, :assertion_consumer_service_url,
                  :entity_id, :name, :description, :name_id_format

      def initialize(client, identity_provider, assertion_consumer_service_url, entity_id, options = {})
        @client = client
        @identity_provider = identity_provider
        @assertion_consumer_service_url = assertion_consumer_service_url
        @entity_id = entity_id
        @name = options[:name] || nil
        @description = options[:description] || nil
        @name_id_format = options[:name_id_format] || nil
      end

      def call
        map_identity_provider_and_service_provider
        service_provider
      end

      private

      def map_identity_provider_and_service_provider
        identity_provider.saml_service_provider_registrations.create(
          service_provider: { href: service_provider.href }
        )
      end

      def service_provider
        @service_provider ||= data_store.create(
          service_provider_registration_href,
          registered_service_provider_attempt,
          Stormpath::Resource::RegisteredSamlServiceProvider
        )
      end

      def registered_service_provider_attempt
        @registered_service_provider_attempt ||=
          data_store.instantiate(RegisteredServiceProviderAttempt).set_attributes(
            assertion_consumer_service_url: assertion_consumer_service_url,
            entity_id: entity_id,
            name: name,
            description: description,
            name_id_format: name_id_format
          )
      end

      def service_provider_registration_href
        "#{data_store.base_url}/registeredSamlServiceProviders"
      end
    end
  end
end
