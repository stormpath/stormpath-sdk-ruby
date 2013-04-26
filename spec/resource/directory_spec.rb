require 'spec_helper'

describe Stormpath::Resource::Directory do
  describe '#create_account' do
    # Refers to a directory on the test Stormpath login named FixtureApplicationA Directory
    let(:directory) { test_api_client.directories.get '/directories/xYzxowbFhG9vPAb6fkqAt' }

    context 'given a valid account' do
      let(:account) do
        Stormpath::Resource::Account.new({
          email: "#{generate_resource_name}@example.com",
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "#{generate_resource_name}username"
        })
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
