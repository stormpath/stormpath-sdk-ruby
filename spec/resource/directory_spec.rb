require 'spec_helper'

describe Stormpath::Directory do
  describe '#create_account' do
    # Refers to a directory on the test Stormpath login named FixtureApplicationA Directory
    let(:directory) { Stormpath::Directory.get test_api_client, '/directories/xYzxowbFhG9vPAb6fkqAt' }

    context 'given a valid account' do
      let(:account) do
        account = Stormpath::Account.new test_api_client
        account.email = "#{generate_resource_name}@example.com"
        account.given_name = 'Ruby SDK'
        account.password = 'P@$$w0rd'
        account.surname = 'SDK'
        account.username = "#{generate_resource_name}username"
        account
      end
      let(:created_account) { directory.create_account account, false }

      after do
        created_account.delete if created_account
      end

      it 'creates an account' do
        created_account.should be
        created_account.username.should == account.username
      end
    end
  end
end
