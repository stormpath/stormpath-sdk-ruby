require 'spec_helper'

describe Stormpath::Resource::Organization, :vcr do

  let(:organization) do 
    test_api_client.organizations.create name: 'test_organization',
       name_key: "testorganization"
  end

  after do
    organization.delete if organization
  end

  def create_organization_account_store_mapping(organization, account_store)
    test_api_client.organization_account_store_mappings.create({
      account_store: { href: account_store.href },
      organization: { href: organization.href }
    })
  end

  describe 'get resource' do
    let(:fetched_organization) { test_api_client.organizations.get organization.href }

    it 'returnes the organization resource with correct attribute properties' do
      expect(fetched_organization).to be_kind_of(Stormpath::Resource::Organization)
      expect(fetched_organization.name).to eq(organization.name)
      expect(fetched_organization.description).to eq(organization.description)
      expect(fetched_organization.name_key).to eq(organization.name_key)
      expect(fetched_organization.status).to eq(organization.status)
      expect(fetched_organization.account_store_mappings).to eq(organization.account_store_mappings)
      expect(fetched_organization.default_account_store_mapping).to eq(organization.default_account_store_mapping)
      expect(fetched_organization.default_group_store_mapping).to eq(organization.default_group_store_mapping)
    end

    it 'returnes custom_data' do
      expect(organization.custom_data).to be_a Stormpath::Resource::CustomData
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

  describe 'associations' do
    context 'groups' do

      let(:directory) { test_api_client.directories.create name: random_directory_name }    
    
      let(:group) { directory.groups.create name: "test_group" }    

      before do 
        create_organization_account_store_mapping(organization, group)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returnes a collection of groups' do
        expect(organization.groups).to be_kind_of(Stormpath::Resource::Collection)
        expect(organization.groups).to include(group)
      end
    end 

    context 'accounts' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }    

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }
    
      before do 
        create_organization_account_store_mapping(organization, directory)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returnes a collection of groups' do
        expect(organization.accounts).to be_kind_of(Stormpath::Resource::Collection)
        expect(organization.accounts).to include(account)
      end
    end

    context 'tenant' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }    
    
      before do 
        create_organization_account_store_mapping(organization, directory)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returnes tenant' do
        expect(organization.tenant).to eq(directory.tenant)
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
