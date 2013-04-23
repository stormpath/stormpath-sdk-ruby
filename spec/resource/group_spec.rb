
require 'spec_helper'

describe Stormpath::Group do
  describe '#add_account' do
    context "given an account" do
      let(:directory) do
        directory = test_api_client.data_store.instantiate Stormpath::Directory
        directory.name = generate_resource_name
        directory = test_api_client.data_store.create '/directories', directory, Stormpath::Directory
      end

      let(:group) do
        group = Stormpath::Group.new test_api_client
        group.name = generate_resource_name
        test_api_client.data_store.create "#{directory.href}/groups", group, Stormpath::Group
      end

      let(:account) do
        account = Stormpath::Account.new test_api_client
        account.email = 'rubysdk@email.com'
        account.given_name = 'Ruby SDK'
        account.password = 'P@$$w0rd'
        account.surname = 'SDK'
        account.username = 'rubysdk'
        directory.create_account account, false
      end

      let(:reloaded_account) do
        Stormpath::Account.get test_api_client, account.href
      end

      let(:reloaded_group) do
        Stormpath::Group.get test_api_client, group.href
      end

      before do
        group.add_account account
      end

      it "adds the account to the group" do
        account_added = false
        reloaded_group.accounts.each do |a|
          account_added = true if a.href == account.href
        end
        account_added.should be_true
      end
    end
  end
end
