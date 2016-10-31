require 'spec_helper'

describe Stormpath::Resource::Organization, :vcr do

  let(:organization) do
    test_api_client.organizations.create name: 'test_ruby_organization',
       name_key: "testorganization", description: 'test organization'
  end

  after do
    organization.delete if organization
  end

  describe "instances should respond to attribute property methods" do
    it do
      [:name, :description, :name_key, :status].each do |property_accessor|
        expect(organization).to respond_to(property_accessor)
        expect(organization).to respond_to("#{property_accessor}=")
        expect(organization.send property_accessor).to be_a String
      end

      [:created_at, :modified_at].each do |property_getter|
        expect(organization).to respond_to(property_getter)
        expect(organization.send property_getter).to be_a String
      end

      expect(organization.tenant).to be_a Stormpath::Resource::Tenant
      expect(organization.custom_data).to be_a Stormpath::Resource::CustomData
      expect(organization.groups).to be_a Stormpath::Resource::Collection
      expect(organization.accounts).to be_a Stormpath::Resource::Collection
    end
  end

  describe 'get resource' do
    let(:fetched_organization) { test_api_client.organizations.get organization.href }

    it 'returns the organization resource with correct attribute properties' do
      expect(fetched_organization).to be_kind_of(Stormpath::Resource::Organization)
      expect(fetched_organization.name).to eq(organization.name)
      expect(fetched_organization.description).to eq(organization.description)
      expect(fetched_organization.name_key).to eq(organization.name_key)
      expect(fetched_organization.status).to eq(organization.status)
      expect(fetched_organization.account_store_mappings).to eq(organization.account_store_mappings)
      expect(fetched_organization.default_account_store_mapping).to eq(organization.default_account_store_mapping)
      expect(fetched_organization.default_group_store_mapping).to eq(organization.default_group_store_mapping)
    end

    it 'returns custom_data' do
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
        map_organization_store(group, organization)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returns a collection of groups' do
        expect(organization.groups).to be_kind_of(Stormpath::Resource::Collection)
        expect(organization.groups).to include(group)
      end
    end

    context 'accounts' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }

      let(:account) do
        directory.accounts.create(
          email: 'rubysdk@example.com',
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK'
        )
      end
      let(:org_account) do
        organization.accounts.create(
          email: 'rubysdk2@example.com',
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK'
        )
      end

      before do
        map_organization_store(directory, organization, true)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returns a collection of accounts' do
        expect(organization.accounts).to be_kind_of(Stormpath::Resource::Collection)
        expect(organization.accounts).to include(account)
      end

      it 'can create another account' do
        expect(org_account).to be_kind_of(Stormpath::Resource::Account)
        expect(organization.accounts).to include(org_account)
      end

      it 'can get a specific account' do
        expect(org_account).to be_kind_of(Stormpath::Resource::Account)
        expect(organization.accounts.get(org_account.href)).to eq org_account
      end
    end

    context 'tenant' do
      let(:directory) { test_api_client.directories.create name: random_directory_name }

      before do
        map_organization_store(directory, organization)
      end

      after do
        organization.delete if organization
        directory.delete if directory
      end

      it 'returns tenant' do
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
        map_organization_store(directory, organization)
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
        map_organization_store(group, organization)
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
