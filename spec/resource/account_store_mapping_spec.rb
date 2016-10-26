require 'spec_helper'

describe Stormpath::Resource::AccountStoreMapping, :vcr do
  let(:directory_name) { random_directory_name }

  let(:directory) { test_api_client.directories.create name: directory_name, description: 'testDirectory for AccountStoreMappings' }

  let(:application) { test_api_client.applications.create name: random_application_name, description: 'testApplication for AccountStoreMappings' }

  after do
    application.delete if application
    directory.delete if directory
  end

  describe "instances" do
    let!(:account_store_mapping) do
      map_account_store(application, directory, 0, true, false)
    end

    it do
      [:list_index, :is_default_account_store, :is_default_group_store, :default_account_store, :default_group_store ].each do |prop_accessor|
        expect(account_store_mapping).to respond_to(prop_accessor)
        expect(account_store_mapping).to respond_to("#{prop_accessor}=")
      end

      [:default_account_store?, :default_group_store?].each do |prop_getter|
        expect(account_store_mapping).to respond_to(prop_getter)
      end

      expect(account_store_mapping.list_index).to be_a Fixnum

      [:default_account_store, :default_group_store].each do |default_store_method|
        [default_store_method, "is_#{default_store_method}", "#{default_store_method}?"].each do |specific_store_method|
          expect(account_store_mapping.send specific_store_method).to be_boolean
        end
      end

      expect(account_store_mapping.account_store).to be_a Stormpath::Resource::Directory
      expect(account_store_mapping.application).to be_a Stormpath::Resource::Application
    end
  end


  describe 'given an application' do
    let(:reloaded_application) { test_api_client.applications.get application.href }

    context 'on application creation' do
      it 'there should be no default account/group store' do
        expect(application.default_account_store_mapping).to eq(nil)
        expect(application.default_group_store_mapping).to eq(nil)
      end
    end

    it 'should retrive a default account store mapping one is created' do
      account_store_mapping = map_account_store(application, directory, 0, true, true)
      expect(reloaded_application.default_account_store_mapping).to eq(account_store_mapping)
    end

    it 'should retrive a default group store mapping when one is created' do
      account_store_mapping = map_account_store(application, directory, 0, true, true)
      expect(reloaded_application.default_group_store_mapping).to eq(account_store_mapping)
    end

    it 'change the default account store mapping, the application needs to be reloaded' do
      account_store_mapping = map_account_store(application, directory, 0, true, false)
      expect(application.default_account_store_mapping).to eq(nil)
      expect(reloaded_application.default_account_store_mapping).to eq(account_store_mapping)
    end

    it 'change the default group store mapping, the application needs to be reloaded' do
      account_store_mapping = map_account_store(application, directory, 0, true, true)
      expect(application.default_group_store_mapping).to eq(nil)
      expect(reloaded_application.default_group_store_mapping).to eq(account_store_mapping)
    end

    context 'remove the added default account/group store mapping' do
      let(:re_reloaded_application) { test_api_client.applications.get application.href }

      it 'there should not be a default account store mapping in the beginning and the end' do
        expect(application.default_account_store_mapping).to eq(nil)
        account_store_mapping = map_account_store(application, directory, 0, true, false)

        expect(application.default_account_store_mapping).to eq(nil)
        expect(reloaded_application.default_account_store_mapping).to eq(account_store_mapping)

        account_store_mapping.is_default_account_store = false
        account_store_mapping.save

        expect(application.default_account_store_mapping).to eq(nil)
        expect(reloaded_application.default_account_store_mapping).to eq(account_store_mapping)
        expect(re_reloaded_application.default_account_store_mapping).to eq(nil)
      end

      it 'there should not be a default group store mapping in the beginning and the end' do
        expect(application.default_account_store_mapping).to eq(nil)
        account_store_mapping = map_account_store(application, directory, 0, false, true)

        expect(application.default_group_store_mapping).to eq(nil)
        expect(reloaded_application.default_group_store_mapping).to eq(account_store_mapping)

        account_store_mapping.is_default_group_store = false
        account_store_mapping.save

        expect(application.default_group_store_mapping).to eq(nil)
        expect(reloaded_application.default_group_store_mapping).to eq(account_store_mapping)
        expect(re_reloaded_application.default_group_store_mapping).to eq(nil)
      end
    end

  end

  describe "given a directory" do
    before { map_account_store(application, directory, 0, false, false) }

    it 'add an account store mapping' do
      expect(application.account_store_mappings.count).to eq(1)
    end
  end

  describe "given a group" do
    let(:group) { directory.groups.create name: 'testGroup', description: 'testGroup for AccountStoreMappings' }
    let(:reloaded_application) { test_api_client.applications.get application.href }

    after do
      group.delete if group
    end

    context 'add an account store mapping' do
      it 'being a default account store' do
        account_store_mapping = map_account_store(application, group, 0, true, false)
        expect(application.default_account_store_mapping).to eq(nil)
        expect(application.account_store_mappings.count).to eq(1)
        expect(reloaded_application.default_account_store_mapping).to eq(account_store_mapping)
      end

      it 'being a default group store, should raise an error' do
        expect do
          map_account_store(application, group, 0, false, true)
        end.to raise_error Stormpath::Error
      end

    end

  end

  describe "update attribute default_group_store" do
    let(:account_store_mapping) { map_account_store(application, directory, 0, true, false) }
    let(:reloaded_mapping){ application.account_store_mappings.get account_store_mapping.href }

    it 'should go from true to false' do
      expect(account_store_mapping.is_default_account_store).to eq(true)
      account_store_mapping.default_account_store= false
      account_store_mapping.save
      expect(reloaded_mapping.is_default_account_store).to eq(false)
    end
  end

  describe "given a mapping" do
    let!(:account_store_mapping) { map_account_store(application, directory, 0, true, false) }
    let(:reloaded_application) { test_api_client.applications.get application.href}

    it 'function delete should destroy it' do
      expect(application.account_store_mappings.count).to eq(1)
      account_store_mapping.delete
      expect(reloaded_application.account_store_mappings.count).to eq(0)
    end

    it 'should be able to list its attributes' do
      reloaded_application.account_store_mappings.each do |account_store_mapping|
        expect(account_store_mapping.account_store.name).to eq(directory_name)
        expect(account_store_mapping.list_index).to eq(0)
        expect(account_store_mapping.default_account_store?).to eq(true)
        expect(account_store_mapping.default_group_store?).to eq(false)
      end
    end
  end
end
