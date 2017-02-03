require 'spec_helper'

describe Stormpath::Resource::RegisteredSamlServiceProvider, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:identity_provider) { application.saml_policy.identity_provider }
  let(:assertion_consumer_service_url) { 'https://some.sp.com/saml/sso/post' }
  let(:entity_id) { 'urn:sp:A1B2C3' }
  let(:options) { { name: random_number, description: random_number } }
  let(:registered_service_provider) do
    identity_provider.register_service_provider(assertion_consumer_service_url, entity_id, options)
  end

  after do
    registered_service_provider.delete
    application.delete
  end

  it 'instances should respond to attribute property methods' do
    expect(registered_service_provider).to be_a Stormpath::Resource::RegisteredSamlServiceProvider

    [:created_at, :modified_at].each do |prop_reader|
      expect(registered_service_provider).to respond_to(prop_reader)
      expect(registered_service_provider.send(prop_reader)).to be_a String
    end

    [:name, :description, :assertion_consumer_service_url,
     :entity_id, :name_id_format].each do |prop_accessor|
       expect(registered_service_provider).to respond_to(prop_accessor)
       expect(registered_service_provider).to respond_to("#{prop_accessor}=")
     end

    expect(registered_service_provider.encoded_x509_certificate).to be_nil
  end
end
