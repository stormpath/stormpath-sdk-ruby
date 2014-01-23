require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do
  describe '#add_or_remove_account' do
    context "given an account" do

      let(:directory) { test_api_client.directories.create name: 'testDirectory' }

      let(:group) { directory.groups.create name: 'someGroup' }

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

      let(:reloaded_account) { test_api_client.accounts.get account.href }

      let(:reloaded_group) { test_api_client.groups.get group.href }

      let(:reloaded_group_2) { test_api_client.groups.get group.href }

      before { group.add_account account }

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      it "adds the account to the group" do
        expect(reloaded_group.accounts).to include(account)
      end

      it 'has one account membership resource' do
        expect(reloaded_group.account_memberships).to have(1).item
      end

      xit 'adds and removes the group from the account' do
        expect(reloaded_group.accounts).to include(account)
        reloaded_group.remove_account account
        expect(reloaded_group_2.accounts).not_to include(account)
      end

    end
  end
end
