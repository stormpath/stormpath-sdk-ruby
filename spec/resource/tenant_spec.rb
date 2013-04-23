require 'spec_helper'

describe Stormpath::Tenant do
  describe '#create_account' do
    context 'given an application instance' do
      let(:client) { Stormpath::Client.new api_key: test_api_key }
      let(:tenant) { client.current_tenant }
      let(:application) do
        Stormpath::Application.new client,
          name: generate_resource_name,
          description: 'A test description'
      end
      let(:created_application) { tenant.create_application application }

      it 'creates that appication' do
        created_application.should be
        created_application.name.should == application.name
        created_application.description.should == application.description
      end
    end
  end

  describe '#verify_account_email' do
    context 'given a verfication token of an account' do
      let(:directory) do
        Stormpath::Directory.get test_api_client, '/directories/1tQTWUpMHyNSHxK8WIry2l'
      end
      let(:account) do
        account = Stormpath::Account.new test_api_client,
          email: "#{generate_resource_name}@example.com",
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "#{generate_resource_name}username"
        directory.create_account account
      end
      let(:verification_token) do
        account.email_verification_token.href.split('/').last
      end
      let(:verified_account) do
        test_api_client.current_tenant.verify_account_email verification_token
      end

      after do
        account.delete if account
      end

      it 'returns the account' do
        verified_account.should be
        verified_account.should be_kind_of Stormpath::Account
        verified_account.username.should == account.username
      end
    end
  end
end
