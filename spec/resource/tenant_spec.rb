require 'spec_helper'

describe Stormpath::Resource::Tenant, :vcr do
  describe '#create_account' do
    context 'given an application instance' do
      let(:tenant) { test_api_client.tenant }

      let(:application) do
        Stormpath::Resource::Application.new({
          name: 'testApplication',
          description: 'A test description'
        })
      end

      let(:created_application) { test_api_client.applications.create application }

      after do
        created_application.delete if created_application
      end

      it 'creates that appication' do
        created_application.should be
        created_application.name.should == application.name
        created_application.description.should == application.description
      end
    end
  end

  describe '#verify_account_email' do
    context 'given a verfication token of an account' do
      let(:directory) { test_directory_with_verification }

      let(:account) do
        account = Stormpath::Resource::Account.new({
          email: "test@example.com",
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "testusername"
        })
        directory.create_account account
      end

      let(:verification_token) do
        account.email_verification_token.token
      end

      let(:verified_account) do
        test_api_client.tenant.verify_account_email verification_token
      end

      after do
        account.delete if account
      end

      it 'returns the account' do
        verified_account.should be
        verified_account.should be_kind_of Stormpath::Resource::Account
        verified_account.username.should == account.username
      end
    end
  end
end
