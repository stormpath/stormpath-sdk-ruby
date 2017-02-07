require 'spec_helper'

describe Stormpath::Oauth::AccessTokenAuthenticationResult, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  before { map_account_store(application, directory, 1, true, false) }
  let!(:account) do
    application.accounts.create(account_attrs(email: 'ruby25', password: 'P@$$w0rd'))
  end
  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new("ruby25#{default_domain}", 'P@$$w0rd')
  end
  let(:jwt_authentication_result) { application.authenticate_oauth(password_grant_request) }

  after do
    application.delete
    directory.delete
    account.delete
  end

  it 'instances should expose a method to get an account' do
    expect(jwt_authentication_result.account).to eq(account)
  end

  it 'jwt access token should contain the stt header' do
    expect(jwt_authentication_result.access_token).to have_stt_in_header('access')
  end

  it 'should be able to delete the access token' do
    jwt_authentication_result

    expect(account.access_tokens.count).to eq(1)

    jti = JWT.decode(
      jwt_authentication_result.access_token,
      test_api_client.data_store.api_key.secret
    ).first['jti']

    fetched_access_token = test_api_client.access_tokens.get(jti)

    fetched_access_token.delete

    expect(account.access_tokens.count).to eq(0)
  end

  it 'jwt refresh token should contain the stt header' do
    expect(jwt_authentication_result.refresh_token).to have_stt_in_header('refresh')
  end

  it 'should be able to delete the refresh token' do
    jwt_authentication_result

    expect(account.refresh_tokens.count).to eq(1)

    jti = JWT.decode(
      jwt_authentication_result.refresh_token,
      test_api_client.data_store.api_key.secret
    ).first['jti']

    fetched_refresh_token = test_api_client.refresh_tokens.get(jti)

    fetched_refresh_token.delete

    expect(account.refresh_tokens.count).to eq(0)
  end
end
