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
      if defined? provider_info
        hash[:provider] = provider_info
      end
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

    # [:client_id, :client_secret, :provider_id, :created_at, :modified_at, :href ].each do |attribute|
    #   it { should respond_to attribute }
    # end

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
      
      if(provider_id == "google" || provider_id == "facebook")
        expect(provider.client_id).to eq(client_id)
        expect(provider.client_secret).to eq(client_secret)
        expect(provider).to be_instance_of("Stormpath::Provider::#{provider_id.capitalize}Provider".constantize)
      end
      
      if(provider_id == "google")
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
    let(:client_id) { ENV['STORMPATH_SDK_TEST_FACEBOOK_APP_ID'] }
    let(:client_secret) { ENV['STORMPATH_SDK_TEST_FACEBOOK_APP_SECRET'] }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret }
    end

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "CAATmZBgxF6rMBAJ8NW6ChSnrk4OMxb6WmnH78Mcv3SD4zs5ZCXoeFEP3rBqL7ReAXgN1CGmWpJ2LbihblIPbSqfMEf2XIf4BFarZAqS64dylSomqzzoZChAvfPLZBH8GvVIuF80kCXtwMReIBEzTZBYaRcI215nYVCTaUMm20LdZAamku4qIkAIQEOmhigVVOHSYOZCe7tXE1wZDZD"
      facebook_account_request = Stormpath::Provider::FacebookAccountRequest.new(:access_token, access_token)
      result = application.get_account(facebook_account_request)

      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
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
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri }
    end

    it_behaves_like 'a provider directory'

    it 'syncrhonize account' do
      account_store_mapping

      access_token = "ya29.1.AADtN_XtWwdxVv9_fgh4vkpu24EjcOKnXvFUw2SxuR6pYX1EhlQXMyLHW5uleg"
      google_account_request = Stormpath::Provider::GoogleAccountRequest.new(:access_token, access_token)
      result = application.get_account(google_account_request)

      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)
      expect(result.account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
      expect(result.account.provider_data.provider_id).to eq("google")

      new_result = application.get_account(google_account_request)
      expect(new_result.is_new_account).not_to be
    end
  end
end
