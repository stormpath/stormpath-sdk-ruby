require 'spec_helper'

describe Stormpath::Resource::AccessToken, :vcr do
  describe "instances should expose a method to get an account" do
    let(:directory) { test_directory }

    let(:application) { test_application }

    let(:account_data) { build_account }

    let(:account) { directory.accounts.create(account_data) }

    let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new account_data[:email], account_data[:password] }

    let(:access_token) { application.authenticate_oauth(password_grant_request) }

    before { account }
    after { account.delete }

    it 'should be the same as the original account' do
      expect(access_token.account).to eq(account)
    end
  end
end
