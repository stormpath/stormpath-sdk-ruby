require 'spec_helper'

describe Stormpath::Resource::Provider, :vcr do

  let(:application) do 
    test_api_client.applications.create name: 'Test Provider Application', 
                                        description: 'Test Provider Application for AccountStoreMappings'
  end

  let(:account_store_mapping) do
    test_api_client.account_store_mappings.create application: application,
                                                  account_store: directory
  end

  let(:directory) do
    test_api_client.directories.create name: name, 
                                       description: description,
                                       provider: { provider_id: provider_id,
                                                   client_id: client_id,
                                                   client_secret: client_secret,
                                                   redirect_uri: redirect_uri }
  end

  subject(:provider) do
    directory.provider
  end

  after do
    directory.delete
    application.delete
  end

  shared_examples 'a provider directory' do
    it { should be_instance_of Stormpath::Resource::Provider }

    [:client_id, :client_secret, :provider_id, :created_at, :modified_at, :href, :redirect_uri ].each do |attribute|
      it { should respond_to attribute }
    end

    it 'should properly respond to attributes' do
      expect(provider.provider_id).to eq(provider_id)
      expect(provider.client_id).to eq(client_id)
      expect(provider.client_secret).to eq(client_secret)
      expect(provider.href).to eq(directory.href + "/provider")
      expect(provider.redirect_uri).to eq(redirect_uri)
    end

    it "assign provider directory to an application" do
      expect(application.account_store_mappings).to have(0).items
      expect(account_store_mapping.application).to eq(application)
      expect(account_store_mapping.account_store).to eq(directory)
      expect(application.account_store_mappings).to have(1).items
    end
  end

  describe 'create facebook directory with provider credentials' do
    let(:name) { 'Facebook Test Directory' }
    let(:description) { 'Directory for testing Facebook directories.' }
    let(:provider_id) { "facebook" }
    let(:client_id) { ENV['STORMPATH_SDK_TEST_FACEBOOK_APP_ID'] }
    let(:client_secret) { ENV['STORMPATH_SDK_TEST_FACEBOOK_APP_SECRET'] }
    let(:redirect_uri) { nil }

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "XYZ"
      facebook_account_request = Stormpath::Authentication::FacebookAccountRequest.new(:access_token, access_token)
      result = application.get_account(facebook_account_request)

      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Resource::ProviderData)
      expect(result.account.provider_data.provider_id).to eq("facebook")

      new_result = application.get_account(facebook_account_request)
      expect(new_result.is_new_account).not_to be
    end
  end

  describe 'create google directory with provider credentials' do
    let(:name) { 'Google Test Directory' }
    let(:description) { 'Directory for testing Google directories.' }
    let(:provider_id) { "google" }
    let(:client_id) { ENV['STORMPATH_SDK_TEST_GOOGLE_CLIENT_ID'] }
    let(:client_secret) { ENV['STORMPATH_SDK_TEST_GOOGLE_CLIENT_SECRET'] }
    let(:redirect_uri) { ENV['STORMPATH_SDK_TEST_GOOGLE_REDIRECT_URI'] }

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "XYZ"
      google_account_request = Stormpath::Authentication::GoogleAccountRequest.new(:access_token, access_token)
      result = application.get_account(google_account_request)

      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Resource::ProviderData)
      expect(result.account.provider_data.provider_id).to eq("google")

      new_result = application.get_account(google_account_request)
      expect(new_result.is_new_account).not_to be
    end
  end


  # describe '#nis1ta' do 
  #   let(:directory) do
  #     test_api_client.directories.get("https://api.stormpath.com/v1/directories/2eIMzpGmy5d5ARDpKRti4F")
  #   end

  #   subject(:provider) do
  #     directory.provider
  #   end
    
  #   it { should be_instance_of Stormpath::Resource::Provider }

  #   [:client_id, :client_secret, :provider_id, :created_at, :modified_at].each do |attribute|
  #     it { should respond_to attribute }
  #   end

  #   it 'should have yeah 1' do
  #     expect(provider.provider_id).to eq("facebook")
  #     # expect(:)
  #     # expect(directory)
  #     expect(2).to eq(2)
  #   end
  # end

  # def create_account_store_mapping(application, account_store, is_default_group_store=false)
  #   test_api_client.account_store_mappings.create({
  #     application: application,
  #     account_store: account_store,
  #     list_index: 0,
  #     is_default_account_store: true,
  #     is_default_group_store: is_default_group_store
  #    })
  # end
  
  # let(:application) { test_api_client.applications.create name: 'testApplication', description: 'testApplication for AccountStoreMappings' }
  
  # let(:directory) { test_api_client.directories.create name: 'testDirectory', description: 'testDirectory for AccountStoreMappings' }
  
  # let(:group) { directory.groups.create name: 'testGroup', description: 'testGroup for AccountStoreMappings' }
  
  # after do
  #   application.delete if application
  #   group.delete if group
  #   directory.delete if directory
  # end

  # describe 'given an account_store_mapping and a directory' do
  #   let!(:account_store_mapping) {create_account_store_mapping(application,directory,true)}
  #   let(:reloaded_mapping){ application.account_store_mappings.get account_store_mapping.href }

  #   it 'should return a directory' do
  #     expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Directory)
  #     expect(reloaded_mapping.account_store).to eq(directory)
  #   end

  # end

  #   describe 'given an account_store_mapping and a group' do
  #   let!(:account_store_mapping) {create_account_store_mapping(application,group)}
  #   let(:reloaded_mapping){ application.account_store_mappings.get account_store_mapping.href }

  #   it 'should return a group' do
  #     expect(reloaded_mapping.account_store.class).to eq(Stormpath::Resource::Group)
  #     expect(reloaded_mapping.account_store).to eq(group)
  #   end

  # end

end
