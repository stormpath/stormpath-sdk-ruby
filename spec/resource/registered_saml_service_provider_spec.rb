require 'spec_helper'

describe Stormpath::Resource::RegisteredSamlServiceProvider, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:identity_provider) { application.saml_policy.identity_provider }
  let(:registered_service_provider_attrs) do
    {
      name: 'Example',
      description: 'Exaaample',
      assertion_consumer_service_url: 'https://some.sp.com/saml/sso/post',
      entity_id: 'urn:sp:A1B2C3'
    }
  end
  let(:registered_service_provider) do
    identity_provider.registered_saml_service_providers.create(registered_service_provider_attrs)
  end

  before do
    stub_request(:post, "#{identity_provider.href}/registeredSamlServiceProviders")
      .to_return(body: Stormpath::Test.mocked_registered_service_provider)
  end

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(registered_service_provider).to be_a Stormpath::Resource::RegisteredSamlServiceProvider

    [:name, :description, :assertion_consumer_service_url, :entity_id,
     :name_id_format, :encoded_x509_certificate, :created_at, :modified_at].each do |prop_reader|
      expect(registered_service_provider).to respond_to(prop_reader)
      expect(registered_service_provider.send(prop_reader)).to be_a String
    end

    # TODO: Currently no prop_accessors are enabled because the POST method isn't supported.
    # Check out with Tom!
    # [].each do |property_accessor|
    #   expect(application).to respond_to(property_accessor)
    #   expect(application).to respond_to("#{property_accessor}=")
    #   expect(application.send(property_accessor)).to be_a String
    # end
  end
end
