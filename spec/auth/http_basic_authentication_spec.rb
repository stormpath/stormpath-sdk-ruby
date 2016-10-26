require 'spec_helper'

describe 'HttpBasicAuthentication', vcr: true do
  let(:application) { test_api_client.applications.create(name: 'ruby sdk test app') }
  let(:directory) { test_api_client.directories.create(name: random_directory_name) }
  let(:account) do
    application.accounts.create(
      email: 'test@example.com',
      given_name: 'Ruby SDK',
      password: 'P@$$w0rd',
      surname: 'SDK'
    )
  end
  let(:api_key) { account.api_keys.create({}) }
  let(:api_key_id) { api_key.id }
  let(:api_key_secret) { api_key.secret }
  let(:encoded_api_key) { Base64.encode64("#{api_key_id}:#{api_key_secret}") }
  let(:basic_authorization_header) { "Basic #{encoded_api_key}" }
  let(:authenticate) do
    Stormpath::Authentication::HttpBasicAuthentication.new(application,
                                                           basic_authorization_header).authenticate!
  end

  before do
    test_api_client.account_store_mappings.create(application: application,
                                                  account_store: directory,
                                                  list_index: 1,
                                                  is_default_account_store: true,
                                                  is_default_group_store: true)
  end

  after do
    account.delete
    directory.delete
    application.delete
  end

  describe 'with valid api key id and secret' do
    it 'should return the associated account' do
      expect(authenticate).to eq account
    end
  end

  describe 'with invalid api key id and secret' do
    let(:encoded_api_key) { Base64.encode64('bad_api_key_id:bad_api_key_secret') }

    it 'should raise error' do
      expect do
        authenticate
      end.to raise_error(Stormpath::Error)
    end
  end

  describe 'with valid api key id and bad secret' do
    let(:encoded_api_key) { Base64.encode64("#{api_key_id}:bad_api_key_secret") }

    it 'should raise error' do
      expect do
        authenticate
      end.to raise_error(Stormpath::Error)
    end
  end

  describe 'with no basic authorization header provided' do
    let(:basic_authorization_header) { nil }
    it 'should raise error' do
      expect do
        authenticate
      end.to raise_error(Stormpath::Error)
    end
  end

  context 'with invalid authorization header type' do
    let(:basic_authorization_header) { "Bearer #{encoded_api_key}" }

    it 'should raise error' do
      expect do
        authenticate
      end.to raise_error(Stormpath::Error)
    end
  end
end
