require 'spec_helper'

describe Stormpath::Resource::SamlServiceProviderRegistration, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:identity_provider) { application.saml_policy.identity_provider }
  let(:service_provider_registration_attrs) do
    {
      status: 'ENABLED',
      default_relay_state: 'example_jwt'
    }
  end
  let(:service_provider_registration) do
    identity_provider.saml_service_provider_registrations.create(service_provider_registration_attrs)
  end

  before do
    stub_request(:post, "#{identity_provider.href}/samlServiceProviderRegistrations")
      .to_return(body: Stormpath::Test.mocked_service_provider_registration)
  end

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(service_provider_registration).to be_a Stormpath::Resource::SamlServiceProviderRegistration

    [:created_at, :modified_at].each do |prop_reader|
      expect(service_provider_registration).to respond_to(prop_reader)
      expect(service_provider_registration.send(prop_reader)).to be_a String
    end

    [:status, :default_relay_state].each do |property_accessor|
      expect(service_provider_registration).to respond_to(property_accessor)
      expect(service_provider_registration).to respond_to("#{property_accessor}=")
      expect(service_provider_registration.send(property_accessor)).to be_a String
    end
  end

  describe 'associations' do
    it 'should respond to identity_provider' do
      expect(service_provider_registration.identity_provider).to(
        be_a(Stormpath::Resource::SamlIdentityProvider)
      )
    end

    it 'should respond to service_provider' do
      expect(service_provider_registration.service_provider).to(
        be_a(Stormpath::Resource::RegisteredSamlServiceProvider)
      )
    end
  end
end
