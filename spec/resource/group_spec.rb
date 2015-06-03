require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:directory) { test_directory }

    let(:group) { directory.groups.create name: 'someTestGroup', description: 'someTestDescription' }

    after do
      group.delete if group
    end

    it do
      [:name, :description, :status].each do |property_accessor|
        expect(group).to respond_to(property_accessor)
        expect(group).to respond_to("#{property_accessor}=")
        expect(group.send property_accessor).to be_a String
      end

      expect(group.tenant).to be_a Stormpath::Resource::Tenant
      expect(group.directory).to be_a Stormpath::Resource::Directory
      expect(group.custom_data).to be_a Stormpath::Resource::CustomData
      expect(group.accounts).to be_a Stormpath::Resource::Collection
      expect(group.account_memberships).to be_a Stormpath::Resource::Collection
    end
  end

  describe '#create_group_with_custom_data' do
    let(:directory) { test_directory }

    it 'creates a directory with custom data' do
      directory.custom_data["category"] = "classified"

      directory.save
      expect(directory.custom_data["category"]).to eq("classified")
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
        expect(group.account_memberships.count).to eq(1)
      end

      it 'adds and removes the group from the account' do
        expect(group.accounts).to include(account)

        group.remove_account account

        expect(group.accounts).not_to include(account)
      end

    end
  end
end
