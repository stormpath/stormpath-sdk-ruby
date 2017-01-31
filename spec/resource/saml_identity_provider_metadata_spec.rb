require 'spec_helper'

describe Stormpath::Resource::SamlIdentityProviderMetadata, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:metadata) { application.saml_policy.identity_provider.metadata }

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(metadata).to be_a Stormpath::Resource::SamlIdentityProviderMetadata

    [:entity_id].each do |property_getter|
      expect(metadata).to respond_to(property_getter)
      expect(metadata.send(property_getter)).to be_a String
    end
  end

  describe 'saml identity provider metadata associations' do
    it 'should respond to identity provider' do
      expect(metadata.identity_provider).to be_a Stormpath::Resource::SamlIdentityProvider
    end

    it 'should respond to x509_signing_cert' do
      expect(metadata.x509_signing_cert).to be_a Stormpath::Resource::X509Certificate
    end
  end
end
