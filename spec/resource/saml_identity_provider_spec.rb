require 'spec_helper'

describe Stormpath::Resource::SamlIdentityProvider, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:identity_provider) { application.saml_policy.identity_provider }

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(identity_provider).to be_a Stormpath::Resource::SamlIdentityProvider

    [:sso_login_endpoint].each do |property_getter|
      expect(identity_provider).to respond_to(property_getter)
      expect(identity_provider.send(property_getter)).to be_a Hash
    end

    [:signature_algorithm, :sha_fingerprint, :created_at, :modified_at].each do |property_getter|
      expect(identity_provider).to respond_to(property_getter)
      expect(identity_provider.send(property_getter)).to be_a String
    end

    [:status].each do |property_accessor|
      expect(application).to respond_to(property_accessor)
      expect(application).to respond_to("#{property_accessor}=")
      expect(application.send(property_accessor)).to be_a String
    end
  end

  describe 'saml identity provider associations' do
    it 'should respond to registered_saml_service_providers' do
      expect(identity_provider.registered_saml_service_providers).to(
        be_a(Stormpath::Resource::Collection)
      )
    end

    it 'should respond to saml_service_provider_registrations' do
      expect(identity_provider.saml_service_provider_registrations).to(
        be_a(Stormpath::Resource::Collection)
      )
    end

    it 'should respond to metadata' do
      expect(identity_provider.metadata).to be_a Stormpath::Resource::SamlIdentityProviderMetadata
    end

    describe 'attribute_statement_mapping_rules' do
      let(:rule) do
        { 'name' => 'email',
          'nameFormat' => 'urn:oasis:names:tc:SAML:2.0:nameid-format:entity',
          'accountAttributes' => ['email'] }
      end
      before do
        identity_provider.attribute_statement_mapping_rules.items = [rule]
        identity_provider.attribute_statement_mapping_rules.save
      end

      it 'should respond with attribute_statement_mapping_rules' do
        expect(identity_provider.attribute_statement_mapping_rules).to(
          be_a(Stormpath::Resource::AttributeStatementMappingRules)
        )
      end

      it 'should contain the saved rule' do
        expect(identity_provider.attribute_statement_mapping_rules.items).to include(rule)
      end
    end

    it 'should respond to x509_signing_cert' do
      expect(identity_provider.x509_signing_cert).to be_a Stormpath::Resource::X509Certificate
    end
  end
end
