module Stormpath
  module Authentication
    class RegisterServiceProvider
      attr_reader :client, :identity_provider, :options

      def initialize(identity_provider, options = {})
        @client = identity_provider.client
        @identity_provider = identity_provider
        @options = options
      end

      def call
        map_identity_provider_and_registered_service_provider
        registered_service_provider
      end

      private

      def map_identity_provider_and_registered_service_provider
        identity_provider.saml_service_provider_registrations.create(
          service_provider: { href: registered_service_provider.href }
        )
      end

      def registered_service_provider
        @registered_service_provider ||=
          client.registered_saml_service_providers.create(registered_service_provider_params)
      end

      def registered_service_provider_params
        {}.tap do |body|
          body[:assertion_consumer_service_url] = options[:assertion_consumer_service_url]
          body[:entity_id] = options[:entity_id]
          body[:name] = options[:name]
          body[:description] = options[:description]
          body[:name_id_format] = options[:name_id_format]
        end.compact
      end
    end
  end
end
