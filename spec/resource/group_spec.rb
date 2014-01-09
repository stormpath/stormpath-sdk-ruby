
require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do
  describe '#add_account' do
    context "given an account" do
      let(:directory) do
        test_api_client.directories.create name: 'testDirectory'
      end

      let(:group) do
        directory.groups.create name: 'someGroup'
      end

      let(:account) do
        directory.accounts.create({
          email: 'rubysdk@example.com',
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
        })
      end

      let(:reloaded_account) do
        test_api_client.accounts.get account.href
      end

      let(:reloaded_group) do
        test_api_client.groups.get group.href
      end

      before do
        group.add_account account
      end

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      it "adds the account to the group" do
        expect(reloaded_group.accounts).to include(account)
      end
    end
  end
end
