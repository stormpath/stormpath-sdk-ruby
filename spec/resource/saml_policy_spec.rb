require 'spec_helper'

describe Stormpath::Resource::SamlPolicy, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:saml_policy) { application.saml_policy }

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(saml_policy).to be_a Stormpath::Resource::SamlPolicy

    [:created_at, :modified_at].each do |property_getter|
      expect(saml_policy).to respond_to(property_getter)
      expect(saml_policy.send(property_getter)).to be_a String
    end
  end

  describe 'saml policy associations' do
    xit 'should respond to service_provider' do
      # TODO: this resource should have been added
      # https://stormpath.atlassian.net/wiki/display/AM/Stormpath+as+a+SAML+Service+Provider
      expect(saml_policy.service_provider).to be_a Stormpath::Resource::SamlServiceProvider
    end

    it 'should respond to identity_provider' do
      expect(saml_policy.identity_provider).to be_a Stormpath::Resource::SamlIdentityProvider
    end
  end
end
