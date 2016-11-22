require 'spec_helper'

describe Stormpath::Resource::AccountStore, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:group) { directory.groups.create(group_attrs) }
  let(:organization) { test_api_client.organizations.create(organization_attrs) }

  after do
    application.delete if application
    group.delete if group
    directory.delete if directory
    organization.delete if organization
  end

  describe 'given an account_store_mapping and a directory' do
    let!(:account_store_mapping) { map_account_store(application, directory, 0, true, true) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return a directory' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Directory)
      expect(reloaded_mapping.account_store).to eq(directory)
    end
  end

  describe 'given an account_store_mapping and a group' do
    let!(:account_store_mapping) { map_account_store(application, group, 0, true, false) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return a group' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Group)
      expect(reloaded_mapping.account_store).to eq(group)
    end
  end

  describe 'given an account_store_mapping and an organization' do
    let!(:account_store_mapping) { map_account_store(application, organization, 0, true, false) }
    let(:reloaded_mapping) { application.account_store_mappings.get account_store_mapping.href }

    it 'should return an organization' do
      expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Organization)
      expect(reloaded_mapping.account_store).to eq(organization)
    end
  end

  describe 'given an undefined account_store_mapping' do
    it 'should raise an error' do
      expect do
        map_account_store(application, 'undefined', 0, true, false)
      end.to raise_error
    end
  end
end
