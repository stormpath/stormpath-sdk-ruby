require 'spec_helper'

describe Stormpath::Resource::Account, :vcr do

  describe "instances" do
    let(:directory) { test_api_client.directories.create name: random_directory_name }

    let(:given_name) { 'Ruby SDK' }
    let(:middle_name) { 'Gruby' }
    let(:surname) { 'SDK' }

    subject(:account) do
      directory.accounts.create email: 'test@example.com',
          given_name: given_name,
          password: 'P@$$w0rd',
          middle_name: middle_name,
          surname: surname,
          username: 'rubysdk'
    end

    [:given_name, :username, :middle_name, :surname, :email, :status].each do |property_accessor|
      it { should respond_to property_accessor }
      it { should respond_to "#{property_accessor}=" }
      its(property_accessor) { should be_instance_of String }
    end

    it {should respond_to :full_name}
    its(:full_name) { should be_instance_of String}
    its(:full_name) { should eq("#{given_name} #{middle_name} #{surname}")}

    it {should respond_to "password="}

    its(:tenant) { should be_instance_of Stormpath::Resource::Tenant }
    its(:directory) { should be_instance_of Stormpath::Resource::Directory }
    its(:custom_data) { should be_instance_of Stormpath::Resource::CustomData }
    its(:email_verification_token) { should be_nil }

    its(:groups) { should be_instance_of Stormpath::Resource::Collection }
    its(:group_memberships) { should be_instance_of Stormpath::Resource::Collection }

    after do
      account.delete if account
      directory.delete if directory
    end

  end

  describe 'account_associations' do
    let(:directory) { test_api_client.directories.create name: random_directory_name }

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
      let(:directory) { test_api_client.directories.create name: random_directory_name }

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
