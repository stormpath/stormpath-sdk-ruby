require 'spec_helper'

describe Stormpath::Resource::GroupMembership, :vcr do
  it 'should be the same as AccountMembership' do
    expect(Stormpath::Resource::GroupMembership).to eq(Stormpath::Resource::AccountMembership)
  end

  describe '#add_account' do
    context 'given an account and a group' do
      let(:directory) { test_api_client.directories.create(directory_attrs) }
      let(:group) { directory.groups.create(group_attrs) }
      let(:account) { directory.accounts.create(account_attrs) }

      before { group.add_account account }

      after do
        group.delete
        account.delete
        directory.delete
      end

      it 'group membership and account membership should correspond to each other' do
        expect(group.account_memberships.count).to eq(1)
        expect(account.group_memberships.count).to eq(1)
        expect(group.accounts).to include(account)
        expect(account.groups).to include(group)
        expect(group.account_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
        expect(account.group_memberships.first).to be_a(Stormpath::Resource::GroupMembership)
      end
    end
  end
end
