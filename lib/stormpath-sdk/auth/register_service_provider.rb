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
        # We could use the default create method for resource creation but we need to figure
        # out the best way to create a class that's a RegisteredSamlServiceProvider request
        # (it should be the same as the RegisteredSamlServiceProvider class..can we use it?)
        # @service_provider ||= data_store.create(
        #   service_provider_registration_href,
        #   service_provider_registration_params,
        #   Stormpath::Resource::RegisteredSamlServiceProvider
        # )
        @service_provider ||= data_store.execute_raw_request(
          service_provider_registration_href,
          service_provider_registration_params,
          Stormpath::Resource::RegisteredSamlServiceProvider
        )
      end

      def service_provider_registration_params
        # In case we use the default data_store.create, dont forget to change the parameter
        # names to snake case style
        {}.tap do |body|
          body[:assertionConsumerServiceUrl] = assertion_consumer_service_url
          body[:entityId] = entity_id
          body[:name] = name
          body[:description] = description
          body[:nameIdFormat] = name_id_format
        end.compact
      end

      def service_provider_registration_href
        "#{data_store.base_url}/registeredSamlServiceProviders"
      end
    end
  end
end
