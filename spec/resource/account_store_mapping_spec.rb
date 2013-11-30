require 'spec_helper'

describe Stormpath::Resource::AccountStoreMapping, :vcr do
  
  def create_account_store_mapping(application, account_store)
    test_api_client.account_store_mappings.create({
      application: application,
      account_store: account_store,
      list_index: 0,
      is_defualt_account_store: false,
      is_default_group_store: false
     })
  end

  let(:directory) do
    test_api_client.directories.create name: 'testDirectory', description: 'a testDirectory for Account Store Mappings'
  end
  
  let(:application) do
    test_api_client.applications.create name: 'testApplication', description: 'a testApplication for Account Store Mappings'
  end
  
  after do
    application.delete if application
    directory.delete if directory
  end
    
  describe "instances" do
    subject(:account_store_mapping) {create_account_store_mapping(application,directory)}
   
    it { should respond_to(:account_store) }
    it { should respond_to(:list_index) }
    it { should respond_to(:is_default_group_store) }
    it { should respond_to(:is_default_account_store) }
    it { should respond_to(:application) }
  end

  describe "given a directory" do
    before { create_account_store_mapping(application, directory) }

    it 'add an account store mapping' do
      expect(application.account_store_mappings.count).to eq(1)
    end
  end

  describe "given a group" do
    let(:group) do
      directory.groups.create name: 'testGroup', description: 'a testGroup for Account Store Mappings'
    end

    before { create_account_store_mapping(application, group) }
    after { group.delete if group }

    it 'add an account store mapping' do
      expect(application.account_store_mappings.count).to eq(1)
    end
  end

  describe "update attributes" do
    let(:account_store_mapping) { create_account_store_mapping(application, directory) }
    let(:reloaded_mapping){ application.account_store_mappings.get account_store_mapping.href }

    it 'blabla' do
      expect(account_store_mapping.is_default_group_store).to eq(false)
      account_store_mapping.default_group_store= true
      account_store_mapping.save
      expect(reloaded_mapping.is_default_group_store).to eq(true)
    end
    
  end

end
