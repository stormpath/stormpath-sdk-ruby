require 'spec_helper'

describe Stormpath::Resource::Account, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:directory) { test_api_client.directories.create name: random_directory_name }
    let(:given_name) { 'Ruby SDK' }
    let(:middle_name) { 'Gruby' }
    let(:surname) { 'SDK' }
    let(:account) do
      directory.accounts.create email: 'test@example.com',
          given_name: given_name,
          password: 'P@$$w0rd',
          middle_name: middle_name,
          surname: surname,
          username: 'rubysdk'
    end

    after do
      account.delete if account
      directory.delete if directory
    end

    it do
      [:given_name, :username, :middle_name, :surname, :email, :status].each do |property_accessor|
        expect(account).to respond_to(property_accessor)
        expect(account).to respond_to("#{property_accessor}=")
        expect(account.send property_accessor).to be_a String
      end

      [:created_at, :modified_at, :password_modified_at].each do |property_getter|
        expect(account).to respond_to(property_getter)
        expect(account.send property_getter).to be_a String
      end

      expect(account).to respond_to(:full_name)
      expect(account.full_name).to be_a String
      expect(account.full_name).to eq("#{given_name} #{middle_name} #{surname}")
      expect(account).to respond_to("password=")

      expect(account.tenant).to be_a Stormpath::Resource::Tenant
      expect(account.directory).to be_a Stormpath::Resource::Directory
      expect(account.custom_data).to be_a Stormpath::Resource::CustomData
      expect(account.email_verification_token).to be_nil
      expect(account.groups).to be_a Stormpath::Resource::Collection
      expect(account.group_memberships).to be_a Stormpath::Resource::Collection
      expect(account.applications).to be_a Stormpath::Resource::Collection
    end
  end

  describe 'account_associations' do
    let(:app) { test_api_client.applications.create name: random_application_name, description: 'Dummy desc.' }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create name: random_directory_name }

    before do
      test_api_client.account_store_mappings.create({ application: app, account_store: directory,
        list_index: 1, is_default_account_store: true, is_default_group_store: true })
    end

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

    it 'should have many applications' do
      expect(account.applications.count).to eq(1)
    end

    it 'should belong_to tenant' do
      expect(account.tenant).to be
      expect(account.tenant).to eq(account.directory.tenant)
    end

    after do
      application.delete if application
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
        expect(account.group_memberships.count).to eq(1)
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
      let(:directory) { test_api_client.directories.create name: random_directory_name }
      let(:account) do
        directory.accounts.create build_account
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
        directory.delete if directory
      end

      it 'saves changes to the account' do
        expect(reloaded_account.surname).to eq(new_surname)
      end
    end
  end
end
