require 'spec_helper'

describe Stormpath::Resource::AccessToken, :vcr do
  describe "instances should expose a method to get an account" do
    let(:account_data) { build_account(email: email, password: password) }

    let(:email) { random_email }

    let(:password) { 'P@$$w0rd' }

    let(:account) { test_application.accounts.create(account_data) }

    let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new(email, password) }

    let(:access_token) { test_application.authenticate_oauth(password_grant_request) }

    before { account }
    after { account.delete }

    it 'should be the same as the original account' do
      expect(access_token.account).to eq(account)
    end

    it 'should be deleteable' do
      access_token

      expect(account.access_tokens.count).to eq(1)

      jti = JWT.decode(access_token.access_token, test_api_client.data_store.api_key.secret).first['jti']

      fetched_access_token = test_api_client.access_tokens.get(jti)

      fetched_access_token.delete

      expect(account.access_tokens.count).to eq(0)
    end
  end
end
