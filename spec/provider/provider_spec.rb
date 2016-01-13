require 'spec_helper'

describe Stormpath::Provider::Provider, :vcr do

  let(:application) do
    test_api_client.applications.create name: random_application_name,
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
      expect(application.account_store_mappings.count).to eq(0)
      expect(account_store_mapping.application).to eq(application)
      expect(account_store_mapping.account_store).to eq(directory)
      expect(application.account_store_mappings.count).to eq(1)
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

  shared_examples 'a syncrhonizeable directory' do
    it 'should be able to store provider accounts' do
      account_store_mapping

      access_token = "xyz"
      request = Stormpath::Provider::AccountRequest.new(provider_id, :access_token, access_token)

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test.mocked_account(provider_id), status: 201)
      result = application.get_provider_account(request)
      expect(result.is_new_account?).to be
      expect(result.account).to be_kind_of(Stormpath::Resource::Account)

      stub_request(:get, result.account.href + "/providerData").to_return(body: Stormpath::Test.mocked_provider_data(provider_id))

      expect(result.account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
      provider_data_clazz = "Stormpath::Provider::#{provider_id.capitalize}ProviderData".constantize
      expect(result.account.provider_data).to be_instance_of(provider_data_clazz)

      expect(result.account.provider_data.provider_id).to eq(provider_id)
      expect(result.account.provider_data.created_at).to be
      expect(result.account.provider_data.modified_at).to be
      expect(result.account.provider_data.access_token).to be

      if provider_id == 'google'
        expect(result.account.provider_data.refresh_token).to be
      end

      stub_request(:post, application.href + "/accounts").to_return(body: Stormpath::Test.mocked_account(provider_id), status: 200)
      new_result = application.get_provider_account(request)
      expect(new_result.is_new_account).not_to be
    end
  end

  describe 'create stormpath directory with empty provider credentials' do
    let(:name) { random_directory_name('Stormpath') }
    let(:description) { 'Directory for testing Stormpath directories.' }
    let(:provider_id) { "stormpath" }

    it_behaves_like 'a provider directory'

    it 'should be able to retrieve provider data from a regular account' do
      account = directory.accounts.create({
        given_name: 'John',
        surname: 'Smith',
        email: 'john.smith@example.com',
        username: 'johnsmith',
        password: '4P@$$w0rd!'
      })

      expect(account.provider_data).to be_kind_of(Stormpath::Provider::ProviderData)
      expect(account.provider_data.provider_id).to eq(provider_id)
      expect(account.provider_data.created_at).to be
      expect(account.provider_data.modified_at).to be
      expect(account.provider_data).to be_instance_of(Stormpath::Provider::StormpathProviderData)
    end
  end

  describe 'create facebook directory with provider credentials' do
    let(:name) { random_directory_name('Facebook') }
    let(:description) { 'Directory for testing Facebook directories.' }

    let(:provider_id) { "facebook" }
    let(:client_id) { 'FACEBOOK_APP_ID' }
    let(:client_secret) { 'FACEBOOK_APP_SECRET' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret }
    end

    it_behaves_like 'a provider directory'
    it_behaves_like 'a syncrhonizeable directory'
  end

  describe 'create google directory with provider credentials' do
    let(:name) { random_directory_name('Google') }
    let(:description) { 'Directory for testing Google directories.' }

    let(:provider_id) { "google" }
    let(:client_id) { 'GOOGLE_CLIENT_ID' }
    let(:client_secret) { 'GOOGLE_CLIENT_SECRET' }
    let(:redirect_uri) { 'GOOGLE_REDIRECT_URI' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri }
    end

    it_behaves_like 'a provider directory'
    it_behaves_like 'a syncrhonizeable directory'
  end

  describe 'create linkedin directory with provider credentials' do
    let(:name) { random_directory_name('Linkedin') }
    let(:description) { 'Directory for testing Linkedin directories.' }

    let(:provider_id) { "linkedin" }
    let(:client_id) { 'LINKEDIN_APP_ID' }
    let(:client_secret) { 'LINKEDIN_APP_SECRET' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret }
    end

    it_behaves_like 'a provider directory'
    it_behaves_like 'a syncrhonizeable directory'
  end

  describe 'create github directory with provider credentials' do
    let(:name) { random_directory_name('Github') }
    let(:description) { 'Directory for testing Github directories.' }

    let(:provider_id) { "github" }
    let(:client_id) { 'GITHUB_APP_ID' }
    let(:client_secret) { 'GITHUB_APP_SECRET' }
    let(:provider_info) do
      { provider_id: provider_id, client_id: client_id, client_secret: client_secret }
    end

    it_behaves_like 'a provider directory'
    it_behaves_like 'a syncrhonizeable directory'
  end
end
