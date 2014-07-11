require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:directory) { test_directory }

    subject(:group) { directory.groups.create name: 'someTestGroup', description: 'someTestDescription' }

    [:name, :description, :status].each do |property_accessor|
      it { should respond_to property_accessor }
      it { should respond_to "#{property_accessor}="}
      its(property_accessor) { should be_instance_of String }
    end

    its(:tenant) { should be_instance_of Stormpath::Resource::Tenant }
    its(:directory) { should be_instance_of Stormpath::Resource::Directory }
    its(:custom_data) { should be_instance_of Stormpath::Resource::CustomData }

    its(:accounts) { should be_instance_of Stormpath::Resource::Collection }
    its(:account_memberships) { should be_instance_of Stormpath::Resource::Collection}


    after do
      group.delete if group
    end

  end

  describe '#add_or_remove_account' do
    context "given an account" do

      let(:directory) { test_api_client.directories.create name: random_directory_name }

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
