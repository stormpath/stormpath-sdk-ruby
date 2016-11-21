require 'spec_helper'

describe Stormpath::Resource::Group, :vcr do
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  after { directory.delete }

  describe 'instances should respond to attribute property methods' do
    let(:group) { directory.groups.create name: 'RubyTestGroup', description: 'testDescription' }

    after { group.delete }

    it do
      [:name, :description, :status].each do |property_accessor|
        expect(group).to respond_to(property_accessor)
        expect(group).to respond_to("#{property_accessor}=")
        expect(group.send(property_accessor)).to be_a String
      end

      [:created_at, :modified_at].each do |property_getter|
        expect(group).to respond_to(property_getter)
        expect(group.send(property_getter)).to be_a String
      end

      expect(group.tenant).to be_a Stormpath::Resource::Tenant
      expect(group.directory).to be_a Stormpath::Resource::Directory
      expect(group.custom_data).to be_a Stormpath::Resource::CustomData
      expect(group.accounts).to be_a Stormpath::Resource::Collection
      expect(group.account_memberships).to be_a Stormpath::Resource::Collection
    end
  end

  describe '#create_group_with_custom_data' do
    it 'creates a directory with custom data' do
      directory.custom_data['category'] = 'classified'

      directory.save
      expect(directory.custom_data['category']).to eq('classified')
    end
  end

  describe '#add_or_remove_account' do
    context 'given an account' do
      let(:group) { directory.groups.create(group_attrs) }
      let(:account) { directory.accounts.create(account_attrs) }

      before { group.add_account(account) }

      after do
        group.delete
        account.delete
      end

      it 'adds the account to the group' do
        expect(group.accounts).to include(account)
      end

      it 'has one account membership resource' do
        expect(group.account_memberships.count).to eq(1)
      end

      it 'adds and removes the group from the account' do
        expect(group.accounts).to include(account)
        group.remove_account(account)
        expect(group.accounts).not_to include(account)
      end
    end
  end
end
