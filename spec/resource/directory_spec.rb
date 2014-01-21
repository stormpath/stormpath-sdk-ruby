require 'spec_helper'

describe Stormpath::Resource::Directory, :vcr do
  describe '#create_account' do
    let(:directory) { test_directory }

    context 'given a valid account' do
      let(:account) do
        Stormpath::Resource::Account.new({
          email: "test@example.com",
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "username"
        })
      end

      let(:created_account) { directory.create_account account, false }

      after do
        created_account.delete if created_account
      end

      it 'creates an account' do
        expect(created_account).to be
        expect(created_account.username).to eq(account.username)
      end
    end
  end

  describe '#create_group' do
    let(:directory) { test_directory }

    context 'given a valid group' do
      let(:group_name) { "valid_test_group" }

      let(:created_group) { directory.groups.create name: group_name }

      after do
        created_group.delete if created_group
      end

      it 'creates a group' do
        expect(created_group).to be
        expect(created_group.name).to eq(group_name)
      end
    end
  end

  describe '#delete_directory' do

    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:application) { test_api_client.applications.create name: 'test_application' }

    let!(:group) { directory.groups.create name: 'someGroup' }

    let!(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

    let!(:account_store_mapping) do
      test_api_client.account_store_mappings.create({ application: application, account_store: directory })
    end

    after do
      application.delete if application
    end

    it 'and all of its associations' do
      expect(directory.groups).to have(1).item
      expect(directory.accounts).to have(1).item

      expect(application.account_store_mappings.first.account_store).to eq(directory)

      expect(application.accounts).to include(account)
      expect(application.groups).to include(group)

      expect(application.account_store_mappings).to have(1).item

      directory.delete

      expect(application.account_store_mappings).to have(0).item

      expect(application.accounts).not_to include(account)
      expect(application.groups).not_to include(group)
    end

  end


end
