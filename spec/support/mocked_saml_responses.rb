module Stormpath
  module Test
    def self.mocked_create_saml_directory
      MultiJson.dump(CREATE_SAML_DIRECTORY_REQUEST)
    end

    def self.mocked_create_saml_directory_rules
      MultiJson.dump(CREATE_SAML_DIRECTORY_RULES_REQUEST)
    end

    def self.mocked_saml_directory_provider_response
      MultiJson.dump(GET_SAML_DIRECTORY_PROVIDER)
    end

    def self.mocked_saml_directory_provider_metadata_response
      MultiJson.dump(GET_SAML_DIRECTORY_PROVIDER_METADATA)
    end

    CREATE_SAML_DIRECTORY_REQUEST = {
      href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn',
      name: 'test_directory_',
      description: 'description_for_some_test_directory',
      status: 'ENABLED',
      createdAt: '2016-02-05T11:48:28.970Z',
      modifiedAt: '2016-02-05T11:48:28.970Z',
      tenant: { href: 'https://api.stormpath.com/v1/tenants/3BoGKJZ6kwMlIqWCIYf8hr' },
      provider: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/provider',
        provider_id: 'saml',
        sso_login_url: 'https://yourIdp.com/saml2/sso/login',
        sso_logout_url: 'https://yourIdp.com/saml2/sso/logout',
        encoded_x509_signing_cert: "-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
        request_signature_algorithm: 'RSA-SHA256'
      },
      customData: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/customData'
      },
      passwordPolicy: {
        href: 'https://api.stormpath.com/v1/passwordPolicies/2uH3tJWHS4ZE5R7gcOzmGn'
      },
      accountCreationPolicy: {
        href: 'https://api.stormpath.com/v1/accountCreationPolicies/2uH3tJWHS4ZE5R7gcOzmGn'
      },
      accounts: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/accounts'
      },
      applicationMappings: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/applicationMappings'
      },
      applications: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/applications'
      },
      groups: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/groups'
      },
      organizations: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/organizations'
      },
      organizationMappings: {
        href: 'https://api.stormpath.com/v1/directories/2uH3tJWHS4ZE5R7gcOzmGn/organizationMappings'
      }
    }.freeze

    CREATE_SAML_DIRECTORY_RULES_REQUEST = {
      href:  'https://api.stormpath.com/v1/attributeStatementMappingRules/5Gd35dLZfFI1DB29xA6ZMe',
      createdAt: '2016-01-27T09:52:28.564Z',
      modifiedAt: '2016-02-29T12:58:50.496Z',
      items: [
        {
          name: 'uid4',
          name_format: 'nil',
          account_attributes: ['username']
        }
      ]
    }.freeze

    GET_SAML_DIRECTORY_PROVIDER = {
      href: 'https://api.stormpath.com/v1/directories/5GbnGg4HIqoFdlRjHndYQC/provider',
      createdAt: '2016-01-27T09:52:32.850Z',
      modifiedAt: '2016-01-27T09:52:32.850Z',
      providerId: 'saml',
      ssoLoginUrl: 'https://yourIdp.com/saml2/sso/login',
      ssoLogoutUrl: 'https://yourIdp.com/saml2/sso/logout',
      encoded_x509_signing_cert: "-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
      requestSignatureAlgorithm: 'RSA-SHA256',
      attributeStatementMappingRules: {
        href: 'https://api.stormpath.com/v1/attributeStatementMappingRules/5Gd35dLZfFI1DB29xA6ZMe'
      },
      serviceProviderMetadata: {
        href: 'https://api.stormpath.com/v1/samlServiceProviderMetadatas/5LRVP0EMfrpHYijuqgCUAq'
      }
    }.freeze

    GET_SAML_DIRECTORY_PROVIDER_METADATA = {
      href: 'https://api.stormpath.com/v1/samlServiceProviderMetadatas/5LRVP0EMfrpHYijuqgCUAq',
      createdAt: '2016-01-27T09:52:32.844Z',
      modifiedAt: '2016-01-27T09:52:32.844Z',
      entityId: 'urn:stormpath:directory:5GbnGg4HIqoFdlRjHndYQC:provider:sp',
      assertionConsumerServicePostEndpoint: {
        href: 'https://api.stormpath.com/v1/directories/5GbnGg4HIqoFdlRjHndYQC/saml/sso/post'
      },
      x509SigningCert: {
        href: 'https://api.stormpath.com/v1/x509certificates/5LR5SeoE66qXOAfB1lRqYK'
      }
    }.freeze
  end
end
