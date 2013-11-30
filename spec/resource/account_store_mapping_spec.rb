require 'spec_helper'

describe Stormpath::Resource::AccountStoreMapping, :vcr do
  describe "#create_account_store_mapping" do
    context "given a directory" do
      let(:directory) do
        test_api_client.directories.create name: 'testDirectory', description: 'a testDirectory for Account Store Mappings'
      end

      let(:application) do
        test_api_client.applications.create name: 'testApplication', description: 'a testApplication for Account Store Mappings'
      end

      before do
       test_api_client.account_store_mappings.create({
        application: application,
        account_store: directory,
        list_index: 0,
        is_defualt_account_store: false,
        is_default_group_store: false
       })
      end

      after do
        application.delete if application
        directory.delete if directory
      end

      it 'adds a account store mapping' do
        expect(application.account_store_mappings.count).to eq(1)
      end
    end
  end

  describe "#create_account_store_mapping" do
    context "given a group" do

      let(:directory) do
        test_api_client.directories.create name: 'testDirectory', description: 'a testDirectory for Account Store Mappings'
      end

      let(:group) do
        directory.groups.create name: 'testGroup', description: 'a testGroup for Account Store Mappings'
      end

      let(:application) do
        test_api_client.applications.create name: 'testApplication', description: 'a testApplication for Account Store Mappings'
      end

      before do
       test_api_client.account_store_mappings.create({
        application: application,
        account_store: group,
        list_index: 0,
        is_defualt_account_store: false,
        is_default_group_store: false
       })
      end

      after do
        application.delete if application
        group.delete if group
      end

      it 'adds a account store mapping' do
        expect(application.account_store_mappings.count).to eq(1)
      end
    end
  end

end
