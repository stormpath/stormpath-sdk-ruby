require 'spec_helper'
require 'pry-debugger'

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
    it { should respond_to :middle_name }
    it { should respond_to :full_name }
    it { should respond_to :status }

    it { should respond_to :custom_data }

    after do
      account.delete if account
      directory.delete if directory
    end

  end

  describe 'account_associations' do
    let(:directory) { test_api_client.directories.create name: 'testDirectory' }
    
    let(:account) do
      directory.accounts.create email: 'test@example.com',
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
    end

    it 'should belong_to directory' do
      expect(account.directory).to eq(directory)
    end

    it 'should belong_to tenant' do
      expect(account.tenant).to be
      expect(account.tenant).to eq(account.directory.tenant)
    end

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

      before { account.add_group group }

      after do
        account.delete if account
        group.delete if group
        directory.delete if directory
      end

      it 'adds the group to the account' do
        expect(account.groups).to include(group)
      end

      it 'has one group membership resource' do
        expect(account.group_memberships).to have(1).item
      end

      it 'adds and removes the group from the account' do
        expect(account.groups).to include(group)

        account.remove_group group

        expect(account.groups).not_to include(group)
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
