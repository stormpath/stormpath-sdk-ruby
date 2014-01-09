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

  describe "#add_group" do
    context "given a group" do
      let(:directory) do
        test_api_client.directories.create name: 'testDirectory'
      end

      let(:group) do
        directory.groups.create name: 'testGroup'
      end

      let(:account) do
        directory.accounts.create email: 'test@example.com',
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
      end

      let(:reloaded_account) do
        test_api_client.accounts.get account.href
      end

      before do
        account.add_group group
      end

      after do
        account.delete if account
        group.delete if group
        directory.delete if directory
      end

      it 'adds the group to the account' do
        expect(reloaded_account.groups).to include(group)
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
