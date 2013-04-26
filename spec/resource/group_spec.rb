
require 'spec_helper'

describe Stormpath::Resource::Group do
  describe '#add_account' do
    context "given an account" do
      let(:directory) do
        test_api_client.directories.create name: generate_resource_name
      end

      let(:group) do
        directory.groups.create name: generate_resource_name
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

      let(:reloaded_account) do
        test_api_client.accounts.get account.href
      end

      let(:reloaded_group) do
        test_api_client.groups.get group.href
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
