require 'spec_helper'

describe Stormpath::Resource::Account, :vcr do

  describe "instances" do
    let(:directory) { test_api_client.directories.create name: 'testDirectory' }
    subject(:account) do
      directory.accounts.create email: 'test@example.com',
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
    end

    it { should respond_to :given_name }
    it { should respond_to :username }
    it { should respond_to :surname }
    it { should respond_to :full_name }
    it { should respond_to :custom_data}

    after do
      account.delete if account
      directory.delete if directory
    end

  end

  describe "#add_or_remove_group" do
    context "given a group" do
      let(:directory) { test_api_client.directories.create name: 'testDirectory' }

      let(:group) { directory.groups.create name: 'testGroup' }

      let(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd', surname: 'SDK' }) }

      let(:reloaded_account) { test_api_client.accounts.get account.href }

      let(:reloaded_account_2) { test_api_client.accounts.get account.href }

      before { account.add_group group }

      after do
        account.delete if account
        group.delete if group
        directory.delete if directory
      end

      it 'adds the group to the account' do
        expect(reloaded_account.groups).to include(group)
      end

      it 'has one group membership resource' do
        expect(reloaded_account.group_memberships).to have(1).item
      end

      xit 'adds and removes the group from the account' do
        expect(reloaded_account.groups).to include(group)
        reloaded_account.remove_group group
        expect(reloaded_account_2.groups).not_to include(group)
      end

    end
  end

  describe '#save' do
    context 'when property values have changed' do
      let(:account) do
        test_directory.accounts.create build_account
      end
      let(:account_uri) do
        account.href
      end
      let(:new_surname) do
        "NewSurname"
      end
      let(:reloaded_account) { test_api_client.accounts.get account_uri }

      before do
        account = test_api_client.accounts.get account_uri
        account.surname = new_surname
        account.save
      end

      after do
        account.delete if account
      end

      it 'saves changes to the account' do
        expect(reloaded_account.surname).to eq(new_surname)
      end
    end
  end

end
