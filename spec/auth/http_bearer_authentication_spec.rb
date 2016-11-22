require 'spec_helper'

describe 'HttpBearerAuthentication', vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new("test#{default_domain}", 'P@$$w0rd')
  end
  let(:aquire_token) { application.authenticate_oauth(password_grant_request) }

  let(:access_token) { aquire_token.access_token }
  let(:bearer_authorization_header) { "Bearer #{access_token}" }
  let(:authenticator) { Stormpath::Authentication::HttpBearerAuthentication }
  let(:authenticate_locally) do
    authenticator.new(application, bearer_authorization_header, local: true).authenticate!
  end
  let(:authenticate_remotely) do
    authenticator.new(application, bearer_authorization_header).authenticate!
  end
  before { map_account_store(application, directory, 1, true, true) }
  let!(:account) do
    application.accounts.create(account_attrs(email: 'test', password: 'P@$$w0rd'))
  end

  after do
    account.delete
    directory.delete
    application.delete
  end

  describe 'remote authentication' do
    context 'with a valid bearer authorization header' do
      it 'should return VerifyTokenResult' do
        expect(authenticate_remotely).to be_kind_of(Stormpath::Oauth::VerifyTokenResult)
        expect(authenticate_remotely.account).to eq(account)
      end

      it 'should contain the account' do
        expect(authenticate_remotely.account).to eq(account)
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
        expect(authenticate_locally)
          .to be_kind_of(Stormpath::Oauth::LocalAccessTokenVerificationResult)
        expect(authenticate_locally.account).to eq(account)
      end
    end
  end
end
