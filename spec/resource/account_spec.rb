require 'spec_helper'

describe Stormpath::Account do
  describe "#add_group" do
    context "given a group" do
      let(:directory) do
        directory = test_api_client.data_store.instantiate Stormpath::Directory
        directory.name = generate_resource_name
        directory = test_api_client.data_store.create '/directories', directory, Stormpath::Directory
      end

      let(:group) do
        group = Stormpath::Group.new test_api_client
        group.name = generate_resource_name
        test_api_client.data_store.create "#{directory.href}/groups", group, Stormpath::Group
      end

      let(:account) do
        account = Stormpath::Account.new test_api_client,
          email: 'rubysdk@email.com',
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
        directory.create_account account, false
      end

      let(:reloaded_account) do
        Stormpath::Account.get test_api_client, account.href
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
      let(:reloaded_account) { Stormpath::Account.get test_api_client, account_uri }

      before do
        account = Stormpath::Account.get test_api_client, account_uri
        account.surname = new_surname
        account.save
      end

      it 'saves changes to the account' do
        reloaded_account.surname.should == new_surname
      end
    end
  end
end
