require 'spec_helper'

describe Stormpath::Provider::Provider, :vcr do

  let(:application) do 
    test_api_client.applications.create name: 'Test Provider Application', 
                                        description: 'Test Provider Application for AccountStoreMappings'
  end

  let(:account_store_mapping) do
    test_api_client.account_store_mappings.create application: application, account_store: directory
  end

  let(:directory) do
    test_api_client.directories.create directory_hash
  end

  let(:directory_hash) do
    Hash.new.tap do |hash|
      hash[:name] = name
      hash[:description] = description
      hash[:provider] = provider_info if defined? provider_info
    end
  end

  subject(:provider) do
    directory.provider
  end

  after do
    directory.delete
    application.delete
  end

  shared_examples 'a provider directory' do
    it { should be_kind_of Stormpath::Provider::Provider }

    it "assign provider directory to an application" do
      expect(application.account_store_mappings).to have(0).items
      expect(account_store_mapping.application).to eq(application)
      expect(account_store_mapping.account_store).to eq(directory)
      expect(application.account_store_mappings).to have(1).items
    end

    it 'should properly respond to attributes' do
      expect(provider.provider_id).to eq(provider_id)
      expect(provider.created_at).to be
      expect(provider.modified_at).to be
      expect(provider.href).to eq(directory.href + "/provider")

      provider_clazz = "Stormpath::Provider::#{provider_id.capitalize}Provider".constantize
      expect(provider).to be_instance_of(provider_clazz)

      if provider_id == "google" || provider_id == "facebook"
        expect(provider.client_id).to eq(client_id)
        expect(provider.client_secret).to eq(client_secret)
      end

      if provider_id == "google"
        expect(provider.redirect_uri).to eq(redirect_uri)
      end
    end
  end

  describe 'create stormpath directory with empty provider credentials' do
    let(:name) { 'Stormpath Test Directory' }
    let(:description) { 'Directory for testing Stormpath directories.' }
    let(:provider_id) { "stormpath" }

    it_behaves_like 'a provider directory'
  end

  describe 'create facebook directory with provider credentials' do
    let(:name) { 'Facebook Test Directory' }
    let(:description) { 'Directory for testing Facebook directories.' }

    let(:provider_id) { "facebook" }
    let(:client_id) { 'FACEBOOK_APP_ID' }
    let(:client_secret) { 'FACEBOOK_APP_SECRET' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret }
    end

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "xyz"
      facebook_account_request = Stormpath::Provider::FacebookAccountRequest.new(:access_token, access_token)

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test::FACEBOOK_ACCOUNT, status: 201)
      result = application.get_provider_account(facebook_account_request)
      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)

      stub_request(:get, result.account.href + "/providerData").to_return(body: Stormpath::Test::FACEBOOK_PROVIDER_DATA)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
      expect(result.account.provider_data).to be_instance_of(Stormpath::Provider::FacebookProviderData)
      expect(result.account.provider_data.provider_id).to eq(provider_id)

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test::FACEBOOK_ACCOUNT, status: 200)
      new_result = application.get_provider_account(facebook_account_request)
      expect(new_result.is_new_account).not_to be
    end
  end

  describe 'create google directory with provider credentials' do
    let(:name) { 'Google Test Directory' }
    let(:description) { 'Directory for testing Google directories.' }

    let(:provider_id) { "google" }
    let(:client_id) { 'GOOGLE_CLIENT_ID' }
    let(:client_secret) { 'GOOGLE_CLIENT_SECRET' }
    let(:redirect_uri) { 'GOOGLE_REDIRECT_URI' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri }
    end

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "xyz"
      google_account_request = Stormpath::Provider::GoogleAccountRequest.new(:access_token, access_token)

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test::GOOGLE_ACCOUNT, status: 201)
      result = application.get_provider_account(google_account_request)
      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)

      stub_request(:get, result.account.href + "/providerData").to_return(body: Stormpath::Test::GOOGLE_PROVIDER_DATA)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
      expect(result.account.provider_data).to be_instance_of(Stormpath::Provider::GoogleProviderData)
      expect(result.account.provider_data.provider_id).to eq(provider_id)

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test::GOOGLE_ACCOUNT, status: 200)
      new_result = application.get_provider_account(google_account_request)
      expect(new_result.is_new_account).not_to be
    end
  end
end
