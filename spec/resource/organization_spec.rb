require 'spec_helper'

describe Stormpath::Resource::Organization, :vcr do

  let(:organization) do 
    test_api_client.organizations.create name: 'test_organization',
       name_key: "testorganization"
  end

  after do
    organization.delete if organization
  end

  describe 'get resource' do
    let(:fetched_organization) { test_api_client.organizations.get organization.href }
    it 'returnes the organization resource with correct attribute properties' do
      org = test_api_client.organizations.get organization.href
      expect(fetched_organization.name).to eq(organization.name)
      expect(fetched_organization.description).to eq(organization.description)
      expect(fetched_organization.name_key).to eq(organization.name_key)
    end
  end

  describe 'create' do
    context 'invalid data' do
      it 'should raise Stormpath::Error' do
        expect do
          test_api_client.organizations.create name: 'test_organization',
            name_key: "test_org"
        end.to raise_error(Stormpath::Error)
      end
    end
  end
  
  describe 'delete' do
    let(:href) { organization.href }

    before do
      organization.delete
    end

    it 'removes the organization' do
      expect do
        test_api_client.organizations.get href
      end.to raise_error(Stormpath::Error)
    end
  end

  describe 'update' do
    before do
      organization.name_key = "changed-test-organization"
      organization.save
    end

    it 'can change the data of the existing organization' do
      org = test_api_client.organizations.get organization.href
      expect(org.name_key).to eq("changed-test-organization")
    end
  end

  describe 'organization account store mapping' do
    def create_organization_account_store_mapping(organization, account_store)
      test_api_client.organization_account_store_mappings.create({
        account_store: { href: account_store.href },
        organization: { href: organization.href }
      })
    end

    context 'given an account_store is a directory' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }    

      let(:organization_account_store_mapping) do
        create_organization_account_store_mapping(organization, directory)
      end
  
      let(:reloaded_mapping) do
        test_api_client.account_store_mappings.get organization_account_store_mapping.href
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'should return a directory' do
        expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Directory)
        expect(reloaded_mapping.account_store).to eq(directory)
      end
    end

    context 'given an account_store is a group' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }    
    
      let(:group) { directory.groups.create name: "test_group" }    

      let(:organization_account_store_mapping) do
        create_organization_account_store_mapping(organization, group)
      end

      let(:reloaded_mapping) do
        test_api_client.account_store_mappings.get organization_account_store_mapping.href
      end

      after do
        organization.delete if organization
        group.delete if group
        directory.delete if directory
      end

      it 'should return group' do
        expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Group)
        expect(reloaded_mapping.account_store).to eq(group)
      end
    end
  end
end
