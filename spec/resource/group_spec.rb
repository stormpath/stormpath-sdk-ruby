require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:directory) { test_directory }

    subject(:group) { directory.groups.create name: 'someTestGroup' }

    it { should respond_to(:href) }
    it { should respond_to(:name) }
    it { should respond_to(:description) }
    it { should respond_to(:status) }

    after do
      group.delete if group
    end

  end

  describe '#add_or_remove_account' do
    context "given an account" do

      let(:directory) { test_api_client.directories.create name: 'testDirectory' }

      let(:group) { directory.groups.create name: 'someGroup' }

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

      before do
        group.add_account account
      end

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      it "adds the account to the group" do
        expect(group.accounts).to include(account)
      end

      it 'has one account membership resource' do
        expect(group.account_memberships).to have(1).item
      end

      it 'adds and removes the group from the account' do
        expect(group.accounts).to include(account)

        group.remove_account account

        expect(group.accounts).not_to include(account)
      end

    end
  end
end
