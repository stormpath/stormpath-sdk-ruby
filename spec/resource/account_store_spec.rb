require 'spec_helper'

describe Stormpath::Resource::AccountStore, :vcr do
  def create_account_store_mapping(application, account_store, is_default_group_store = false)
    test_api_client.account_store_mappings.create(
      application: application,
      account_store: account_store,
      list_index: 0,
      is_default_account_store: true,
      is_default_group_store: is_default_group_store
    )
  end

  let(:application) do
    test_api_client.applications.create name: random_application_name,
                                        description: 'testApplication for AccountStoreMappings'
  end

  let(:directory) do
    test_api_client.directories.create name: random_directory_name,
                                       description: 'testDirectory for AccountStoreMappings'
  end

  let(:group) do
    directory.groups.create name: 'testGroup', description: 'testGroup for AccountStoreMappings'
  end

  let(:organization) do
    test_api_client.organizations.create name: 'testOrganization', name_key: 'test-organization'
  end

  after do
    application.delete if application
    group.delete if group
    directory.delete if directory
    organization.delete if organization
  end

  describe 'given an account_store_mapping and a directory' do
    let!(:account_store_mapping) { create_account_store_mapping(application, directory, true) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return a directory' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Directory)
      expect(reloaded_mapping.account_store).to eq(directory)
    end
  end

  describe 'given an account_store_mapping and a group' do
    let!(:account_store_mapping) { create_account_store_mapping(application, group) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return a group' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Group)
      expect(reloaded_mapping.account_store).to eq(group)
    end
  end

  describe 'given an account_store_mapping and a organization' do
    let!(:account_store_mapping) { create_account_store_mapping(application, organization) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return an organization' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Organization)
      expect(reloaded_mapping.account_store).to eq(organization)
    end
  end

  describe 'given an undefined account_store_mapping' do
    it 'should raise an error' do
      expect do
        create_account_store_mapping(application, 'undefined')
      end.to raise_error
    end
  end
end
