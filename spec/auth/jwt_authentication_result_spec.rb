require 'spec_helper'

describe Stormpath::Authentication::JwtAuthenticationResult, :vcr do
  let(:account_data) { build_account(email: email, password: password) }

  let(:email) { random_email }

  let(:password) { 'P@$$w0rd' }

  let(:account) { test_application.accounts.create(account_data) }

  let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new(email, password) }

  let(:jwt_authentication_result) do
    test_application.authenticate_oauth(password_grant_request)
  end

  before { account }
  after { account.delete }

  it 'instances should expose a method to get an account' do
    expect(jwt_authentication_result.account).to eq(account)
  end

  it 'should be able to delete the access token' do
    jwt_authentication_result

    expect(account.access_tokens.count).to eq(1)

    jti = JWT.decode(jwt_authentication_result.access_token, test_api_client.data_store.api_key.secret).first['jti']

    fetched_access_token = test_api_client.access_tokens.get(jti)

    fetched_access_token.delete

    expect(account.access_tokens.count).to eq(0)
  end

  it 'should be able to delete the refresh token' do
    jwt_authentication_result

    expect(account.refresh_tokens.count).to eq(1)

    jti = JWT.decode(jwt_authentication_result.refresh_token, test_api_client.data_store.api_key.secret).first['jti']

    fetched_refresh_token = test_api_client.refresh_tokens.get(jti)

    fetched_refresh_token.delete

    expect(account.refresh_tokens.count).to eq(0)
  end
end
