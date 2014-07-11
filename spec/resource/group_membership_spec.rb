require 'spec_helper'

describe Stormpath::Resource::GroupMembership, :vcr do
  it "should be the same as AccountMembership" do
    expect(Stormpath::Resource::GroupMembership).to eq(Stormpath::Resource::AccountMembership)
  end

  describe '#add_account' do
    context "given an account and a group" do

      let(:directory) { test_api_client.directories.create name: random_directory_name }

      let(:group) { directory.groups.create name: 'someGroup' }

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd', surname: 'SDK' }) }

      before { group.add_account account }

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      it ", group membership and account membership should correspond to each other" do
        expect(group.account_memberships).to have(1).item
        expect(account.group_memberships).to have(1).item
        expect(group.accounts).to include(account)
        expect(account.groups).to include(group)
        expect(group.account_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
        expect(account.group_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
      end
    end
  end
end
