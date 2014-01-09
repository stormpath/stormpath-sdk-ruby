require 'spec_helper'

describe Stormpath::Resource::GroupMembership, :vcr do
  it "should be the same as AccountMembership" do
    expect(Stormpath::Resource::GroupMembership).to eq(Stormpath::Resource::AccountMembership)
  end

  describe '#add_account' do
    context "given an account" do

      let(:directory) { test_api_client.directories.create name: 'testDirectory' }

      let(:group) { directory.groups.create name: 'someGroup' }

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd', surname: 'SDK' }) }

      let(:reloaded_account) { test_api_client.accounts.get account.href }

      let(:reloaded_group) { test_api_client.groups.get group.href }

      before { group.add_account account }

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      it "group and account memberships should correspond to each other" do
        expect(reloaded_group.account_memberships).to have(1).item
        expect(reloaded_account.group_memberships).to have(1).item
        expect(reloaded_group.accounts).to include(account)
        expect(reloaded_account.groups).to include(group)
        expect(reloaded_group.account_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
        expect(reloaded_account.group_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
      end
    end
  end
end
