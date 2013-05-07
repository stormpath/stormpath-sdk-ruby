require 'spec_helper'

describe Stormpath::Resource::Directory, :vcr do
  describe '#create_account' do
    let(:directory) { test_directory }

    context 'given a valid account' do
      let(:account) do
        Stormpath::Resource::Account.new({
          email: "test@example.com",
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "username"
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
