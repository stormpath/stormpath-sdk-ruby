require 'spec_helper'

describe 'HttpBasicAuthentication', vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:account) { application.accounts.create(account_attrs) }
  let(:api_key) { account.api_keys.create({}) }
  let(:api_key_id) { api_key.id }
  let(:api_key_secret) { api_key.secret }
  let(:encoded_api_key) { Base64.encode64("#{api_key_id}:#{api_key_secret}") }
  let(:basic_authorization_header) { "Basic #{encoded_api_key}" }
  let(:authenticator) { Stormpath::Authentication::HttpBasicAuthentication }
  let(:authenticate) { authenticator.new(application, basic_authorization_header).authenticate! }

  before { map_account_store(application, directory, 1, true, true) }

  after do
    account.delete
    directory.delete
    application.delete
  end

  describe 'with valid api key id and secret' do
    it 'should return the apikey resource' do
      expect(authenticate).to be_kind_of Stormpath::Resource::ApiKey
    end

    it 'should return the account' do
      expect(authenticate.account).to eq(account)
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
