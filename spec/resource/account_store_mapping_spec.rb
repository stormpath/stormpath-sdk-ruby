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

  let(:directory) { test_api_client.directories.create name: 'testDirectory', description: 'testDirectory for AccountStoreMappings' }
  
  let(:application) { test_api_client.applications.create name: 'testApplication', description: 'testApplication for AccountStoreMappings' }
  
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
      directory.groups.create name: 'testGroup', description: 'testGroup for AccountStoreMappings'
    end

    before { create_account_store_mapping(application, group) }
    after { group.delete if group }

    it 'add an account store mapping' do
      expect(application.account_store_mappings.count).to eq(1)
    end
  end

  describe "update attribute default_group_store" do
    let(:account_store_mapping) { create_account_store_mapping(application, directory) }
    let(:reloaded_mapping){ application.account_store_mappings.get account_store_mapping.href }

    it 'should go from false to true' do
      expect(account_store_mapping.is_default_group_store).to eq(false)
      account_store_mapping.default_group_store= true
      account_store_mapping.save
      expect(reloaded_mapping.is_default_group_store).to eq(true)
    end

  end

  describe "given a mapping" do
    let!(:account_store_mapping) { create_account_store_mapping(application, directory) }
    let(:reloaded_application) { test_api_client.applications.get application.href}

    it 'function delete should destroy it' do
      expect(application.account_store_mappings.count).to eq(1)
      account_store_mapping.delete
      expect(reloaded_application.account_store_mappings.count).to eq(0)
    end
  
    it 'should be able to list its attributes' do
      reloaded_application.account_store_mappings.each do |account_store_mapping|
        expect(account_store_mapping.account_store.name).to eq("testDirectory")
        expect(account_store_mapping.list_index).to eq(0)
        expect(account_store_mapping.default_account_store?).to eq(false)
        expect(account_store_mapping.default_group_store?).to eq(false)
      end
    end

  end

end
