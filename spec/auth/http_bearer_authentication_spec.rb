require 'spec_helper'

describe 'HttpBearerAuthentication', vcr: true do
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
  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new('test@example.com', 'P@$$w0rd')
  end
  let(:aquire_token) { application.authenticate_oauth(password_grant_request) }

  let(:access_token) { aquire_token.access_token }
  let(:bearer_authorization_header) { "Bearer #{access_token}" }
  let(:authenticate_locally) do
    Stormpath::Authentication::HttpBearerAuthentication.new(application,
                                                            bearer_authorization_header,
                                                            local: true).authenticate!
  end
  let(:authenticate_remotely) do
    Stormpath::Authentication::HttpBearerAuthentication.new(application,
                                                            bearer_authorization_header).authenticate!
  end
  before do
    test_api_client.account_store_mappings.create(application: application,
                                                  account_store: directory,
                                                  list_index: 1,
                                                  is_default_account_store: true,
                                                  is_default_group_store: true)
    account
  end

  after do
    account.delete
    directory.delete
    application.delete
  end

  describe 'remote authentication' do
    context 'with a valid bearer authorization header' do
      it 'should return account' do
        expect(authenticate_remotely).to be_kind_of(Stormpath::Resource::Account)
        expect(authenticate_remotely).to eq(account)
      end
    end

    context 'with no bearer authorization header' do
      let(:bearer_authorization_header) { nil }

      it 'should raise error' do
        expect do
          authenticate_remotely
        end.to raise_error(Stormpath::Error)
      end
    end

    context 'with invalid authorization header type' do
      let(:bearer_authorization_header) { "Basic #{access_token}" }

      it 'should raise error' do
        expect do
          authenticate_remotely
        end.to raise_error(Stormpath::Error)
      end
    end
  end

  describe 'local authentication' do
    context 'with a valid bearer authorization header' do
      it 'should return account' do
        expect(authenticate_locally).to be_kind_of(Stormpath::Resource::Account)
        expect(authenticate_locally).to eq(account)
      end
    end
  end
end
