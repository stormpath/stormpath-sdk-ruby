require 'spec_helper'

describe Stormpath::Resource::SamlIdentityProvider, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:saml_identity_provider) { application.saml_policy.identity_provider }

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(saml_identity_provider).to be_a Stormpath::Resource::SamlIdentityProvider

    [:sso_login_endpoint].each do |property_getter|
      expect(saml_identity_provider).to respond_to(property_getter)
      expect(saml_identity_provider.send(property_getter)).to be_a Hash
    end

    [:signature_algorithm, :sha_fingerprint, :created_at, :modified_at].each do |property_getter|
      expect(saml_identity_provider).to respond_to(property_getter)
      expect(saml_identity_provider.send(property_getter)).to be_a String
    end

    [:status].each do |property_accessor|
      expect(application).to respond_to(property_accessor)
      expect(application).to respond_to("#{property_accessor}=")
      expect(application.send(property_accessor)).to be_a String
    end
  end

  describe 'saml identity provider associations' do
    it 'should respond to registered_service_providers' do
      expect(saml_identity_provider.registered_service_providers).to(
        be_a(Stormpath::Resource::RegisteredSamlServiceProvider)
      )
    end

    it 'should respond to registered_saml_service_provider' do
      expect(saml_identity_provider.registered_saml_service_provider).to(
        be_a(Stormpath::Resource::SamlIdentityProvider)
      )
    end

    it 'should respond to metadata' do
      expect(saml_identity_provider.metadata).to be_a Stormpath::Resource::SamlIdentityProviderMetadata
    end

    it 'should respond to attribute_statement_mapping_rules' do
      expect(saml_identity_provider.attribute_statement_mapping_rules).to(
        be_a(Stormpath::Resource::AttributeStatementMappingRules)
      )
    end

    it 'should respond to x509_signing_cert' do
      expect(saml_identity_provider.x509_signing_cert).to be_a Stormpath::Resource::X509Certificate
    end
  end
end
