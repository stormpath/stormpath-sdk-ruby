require 'spec_helper'

describe Stormpath::Resource::Account do
  describe "#add_group" do
    context "given a group" do
      let(:directory) do
        test_api_client.directories.create name: generate_resource_name
      end

      let(:group) do
        directory.groups.create name: generate_resource_name
      end

      let(:account) do
        directory.accounts.create email: 'rubysdk@email.com',
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

      it 'adds the group to the account' do
        group_added = false
        reloaded_account.groups.each do |g|
          group_added = true if g.href == group.href
        end
        group_added.should be_true
      end
    end
  end

  describe '#save' do
    context 'when property values have changed' do
      let(:account_uri) { '/accounts/3Osia7j72CU2j5I5UwJUjj' }
      let(:new_surname) do
        "NewSurname#{SecureRandom.uuid}"
      end
      let(:reloaded_account) { test_api_client.accounts.get account_uri }

      before do
        account = test_api_client.accounts.get account_uri
        account.surname = new_surname
        account.save
      end

      it 'saves changes to the account' do
        reloaded_account.surname.should == new_surname
      end
    end
  end
end
