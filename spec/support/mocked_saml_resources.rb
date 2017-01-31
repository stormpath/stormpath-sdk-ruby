module Stormpath
  module Test
    def self.mocked_registered_service_provider
      MultiJson.dump(REGISTERED_SERVICE_PROVIDER)
    end

    def self.mocked_service_provider_registration
      MultiJson.dump(SERVICE_PROVIDER_REGISTRATION)
    end

    REGISTERED_SERVICE_PROVIDER = {
      href: 'https://api.stormpath.com/v1/registeredSamlServiceProviders/21355475tfdasd1223',
      createdAt: '2016-09-22T22:35:44.799Z',
      modifiedAt: '2016-09-22T22:39:06.822Z',
      name: 'Example',
      description: 'Exaample',
      assertionConsumerServiceURL: 'https://some.sp.com/saml/sso/post',
      entityId: 'urn:sp:A1B2C3',
      nameIdFormat: 'EMAIL',
      encodedX509Certificate: '...'
    }.freeze
  end

  SERVICE_PROVIDER_REGISTRATION = {
    href: 'https://api.stormpath.com/v1/samlServiceProviderRegistrations/4234jh3vh123bkkl',
    createdAt: '2016-09-22T22:35:44.799Z',
    modifiedAt: '2016-09-22T22:39:06.822Z',
    status: 'enabled',
    defaultRelayState: 'example_jwt'
  }.freeze
end
