require 'spec_helper'

describe 'RegisterServiceProvider', vcr: true do
  let(:client) { test_api_client }
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:identity_provider) { application.saml_policy.identity_provider }
  let(:assertion_consumer_service_url) { "http://example#{random_number}.zendesk.com/access/saml" }
  let(:entity_id) { "unique-name-#{random_number}" }
  let(:registered_service_provider) do
    Stormpath::Authentication::RegisterServiceProvider.new(
      client, identity_provider, assertion_consumer_service_url, entity_id, options
    ).call
  end
  let(:options) { {} }

  after { application.delete }

  describe 'successfull service provider registration' do
    after { registered_service_provider.delete }

    context 'without optional parameters' do
      it 'should successfully create a registered_service_provider' do
        expect(registered_service_provider).to(
          be_a(Stormpath::Resource::RegisteredSamlServiceProvider)
        )
      end

      it 'should successfully map the registered_service_provider to the identity_provider' do
        expect(identity_provider.registered_saml_service_providers).to(
          include(registered_service_provider)
        )
      end
    end

    context 'with optional parameters' do
      let(:options) do
        {
          name: "service-provider-name-#{random_number}",
          description: 'stormpath example',
          name_id_format: 'PERSISTENT'
        }
      end

      it 'should successfully create a registered_service_provider' do
        expect(registered_service_provider).to(
          be_a(Stormpath::Resource::RegisteredSamlServiceProvider)
        )
      end

      it 'should successfully map the registered_service_provider to the identity_provider' do
        expect(identity_provider.registered_saml_service_providers).to(
          include(registered_service_provider)
        )
      end
    end
  end

  describe 'unsuccessfull service provider registration' do
    let(:assertion_consumer_service_url) { nil }

    it 'should raise Stormpath::Error' do
      expect { registered_service_provider }.to raise_error(Stormpath::Error)
    end
  end
end