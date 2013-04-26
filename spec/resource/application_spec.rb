require 'spec_helper'

describe Stormpath::Resource::Application do
  let(:application) do
    test_api_client.applications.get '/applications/xYIjI0liaY4AAxFP1iUz5'
  end

  describe '#authenticate_account' do
    let(:user_name) { 'FixtureUser1' }
    let(:login_request) do
      Stormpath::Authentication::UsernamePasswordRequest.new user_name, password
    end
    let(:expected_email) { 'rudy+fixtureuser1@carbonfive.com' }
    let(:authentication_result) do
      application.authenticate_account login_request
    end

    context 'given a valid username and password' do
      let(:password) {'P@$$w0rd' }

      it 'returns an authentication result' do
        authentication_result.should be
        authentication_result.account.should be
        authentication_result.account.should be_kind_of Stormpath::Resource::Account
        authentication_result.account.email.should == expected_email
      end
    end

    context 'given an invalid username and password' do
      let(:password) { 'b@dP@$$w0rd' }

      it 'raises an error' do
        expect { authentication_result }.to raise_error Stormpath::Error
      end
    end
  end

  describe '.verify_password_reset_token' do
    let(:directory) do
      test_api_client.directories.get '/directories/xYzxowbFhG9vPAb6fkqAt'
    end
    let(:account) do
      directory.accounts.create({
        email: 'rubysdk@email.com',
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: 'rubysdk'
      })
    end
    let(:password_reset_token) do
      application.password_reset_tokens.create(email: account.email).token
    end
    let(:reset_password_account) do
      application.verify_password_reset_token password_reset_token
    end

    after do
      account.delete if account
    end

    it 'retrieves the account with the reset password' do
      reset_password_account.should be
      reset_password_account.email.should == account.email
    end

    context 'and if the password is changed' do
      let(:new_password) { 'N3wP@$$w0rd' }
      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, new_password
      end
      let(:expected_email) { 'rudy+fixtureuser1@carbonfive.com' }
      let(:authentication_result) do
        application.authenticate_account login_request
      end

      before do
        reset_password_account.password = new_password
        reset_password_account.save
      end

      it 'can be successfully authenticated' do
        authentication_result.should be
        authentication_result.account.should be
        authentication_result.account.should be_kind_of Stormpath::Resource::Account
        authentication_result.account.email.should == account.email
      end
    end
  end
end
