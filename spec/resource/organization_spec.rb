require 'spec_helper'

describe Stormpath::Resource::Organization, :vcr do

  let(:organization) do 
    test_api_client.organizations.create name: 'test_organization',
       name_key: "testorganization"
  end

  after do
    organization.delete if organization
  end

  describe 'organization instance should respond to attribute property methods' do
  end

  describe 'organization_associations' do
  end

  describe 'get resource' do
    it 'returnes the organization resource' do
      org = test_api_client.organizations.get organization.href
      expect(org.name).to eq(organization.name)
      expect(org.description).to eq(organization.description)
    end
  end

  describe 'create' do
  end

  describe 'delete' do
  end

  describe 'update' do
  end
end
