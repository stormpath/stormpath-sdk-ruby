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

    def self.mocked_encoded_x509_signing_cert
      <<-HEREDOC
-----BEGIN CERTIFICATE-----
MIIC2DCCAcCgAwIBAgIRAImmW+DAlRHmm+kiAApR5iswDQYJKoZIhvcNAQELBQAw
FDESMBAGA1UEAwwJU3Rvcm1wYXRoMB4XDTE2MTIxMjE4MDUxNloXDTI2MTIxMjE4
MDUxNlowHDEaMBgGA1UEAwwRYXBpLnN0b3JtcGF0aC5jb20wggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQCFy1ClzO6br1+gc8w+G3Y5xRqIM5kE/BqZwZea
ipDnkANUVOnb2ZnVl8iBXu9lzsam0pmsBt9UidjnAh2d7CF0lRGvNSuiWEO72eyZ
99s/EnF8MJwEY+R+M8DQYuKuT9hGcS/mErg8FBY9FFSwXGx6cNAIPvYXl5MbcMb+
xMVdhvc5cdxppwI2jxZCBtekK1poJ7sBjSJWb09Ocv+xtywctLNPX3RlPp6a59e2
ktZGJHRd19ZwD7ef52NJS6n5ozkStUE4RrWbRS6VqgXtG4lZHJadKEUEJHN258Rw
j0qQoa5snG0XM2DTfU7e428MQyU9pzTgSSWQFXZRB8L9LFLFAgMBAAGjHTAbMAkG
A1UdEwQCMAAwDgYDVR0PAQH/BAQDAgWgMA0GCSqGSIb3DQEBCwUAA4IBAQAZo9CK
ytanl5AVmYa5ltb3eZm/CnwoyRzVm0wqcm1o6RTwq5l1JxODCyrolk33HH68Sm1l
v4cmlLqBNtG1XqdBggh9yMX24wAxjXa9SeJnuquJIymL27EcmSL3PVUXWQw+6U8e
pcDwH+Rp7TH0fpSP14xFX0Fgm+fTwUX4eTemm7F39TZfUpNKrwNrqcl+C/yexuTW
vZKewyCkzw44BUsCxKzEjM9Lq6n9A2KAz/qnYG1LszHSpoSvjzzdkRmA0xAdll+5
clqWEoHJw1v932MSZE8+fd+a6AvD85ABvhKci44qs2W6ObXoP8qY6Tov5DlNLEOi
MfF5DfpjJ/btkuRS
-----END CERTIFICATE-----
      HEREDOC
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
