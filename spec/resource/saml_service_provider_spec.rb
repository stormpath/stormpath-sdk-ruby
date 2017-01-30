require 'spec_helper'

describe Stormpath::Resource::SamlServiceProvider, vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:saml_service_provider) { application.saml_policy.service_provider }

  after { application.delete }

  it 'instances should respond to attribute property methods' do
    expect(saml_service_provider).to be_a Stormpath::Resource::SamlServiceProvider

    [:created_at, :modified_at].each do |property_getter|
      expect(saml_service_provider).to respond_to(property_getter)
      expect(saml_service_provider.send(property_getter)).to be_a String
    end

    expect(saml_service_provider.sso_initiation_endpoint).to be_a Hash
  end
end
