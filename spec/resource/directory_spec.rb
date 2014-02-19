require 'spec_helper'

describe Stormpath::Resource::Directory, :vcr do

  describe "instances should respond to attribute property methods" do
    subject(:directory) { test_api_client.directories.create name: 'some_test_directory', description: 'description_for_some_test_directory' }

    it { should be_instance_of Stormpath::Resource::Directory }

    [:name, :description, :status].each do |property_accessor|
      it { should respond_to property_accessor }
      it { should respond_to "#{property_accessor}="}
      its(property_accessor) { should be_instance_of String }
    end

    its(:tenant) { should be_instance_of Stormpath::Resource::Tenant }
    its(:groups) { should be_instance_of Stormpath::Resource::Collection }
    its(:accounts) { should be_instance_of Stormpath::Resource::Collection }

    after do
      directory.delete if directory
    end
  end

  describe 'directory_associations' do
    let(:directory) { test_directory }

    context '#accounts' do
      let(:account) { directory.accounts.create build_account}

      after do
        account.delete if account
      end

      it 'should be able to create an account' do
        expect(directory.accounts).to include(account)
      end

      it 'should be able to create and fetch the account' do
        expect(directory.accounts.get account.href).to be
      end
    end

    context '#groups' do
      let(:group) { directory.groups.create name: "test_group"}

      after do
        group.delete if group
      end

      it 'should be able to create a group' do
        expect(directory.groups).to include(group)
      end

      it 'should be able to create and get a group' do
        expect(directory.groups.get group.href).to be
      end
    end

  end

  describe '#create_account' do
    let(:directory) { test_directory }

    let(:account) do
      Stormpath::Resource::Account.new({
        email: "test@example.com",
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: "username"
      })
    end

    context 'without registration workflow' do

      let(:created_account) { directory.create_account account }

      after do
        created_account.delete if created_account
      end

      it 'creates an account with status ENABLED' do
        expect(created_account).to be
        expect(created_account.username).to eq(account.username)
        expect(created_account).to eq(account)
        expect(created_account.status).to eq("ENABLED")
        expect(created_account.email_verification_token.href).not_to be
      end
    end

    context 'with registration workflow' do

      let(:created_account_with_reg_workflow) { test_directory_with_verification.create_account account }

      after do
        created_account_with_reg_workflow.delete if created_account_with_reg_workflow
      end

      it 'creates an account with status UNVERIFIED' do
        expect(created_account_with_reg_workflow).to be
        expect(created_account_with_reg_workflow.username).to eq(account.username)
        expect(created_account_with_reg_workflow).to eq(account)
        expect(created_account_with_reg_workflow.status).to eq("UNVERIFIED")
        expect(created_account_with_reg_workflow.email_verification_token.href).to be
      end

    end

    context 'with registration workflow but set it to false on account creation' do

      let(:created_account_with_reg_workflow) { test_directory_with_verification.create_account account, false }

      after do
        created_account_with_reg_workflow.delete if created_account_with_reg_workflow
      end

      it 'creates an account with status ENABLED' do
        expect(created_account_with_reg_workflow).to be
        expect(created_account_with_reg_workflow.username).to eq(account.username)
        expect(created_account_with_reg_workflow).to eq(account)
        expect(created_account_with_reg_workflow.status).to eq("ENABLED")
        expect(created_account_with_reg_workflow.email_verification_token.href).not_to be
      end

    end

  end

  describe '#create_account_with_custom_data' do
    let(:directory) { test_directory }

      it 'creates an account with custom data' do
        account =  Stormpath::Resource::Account.new({
          email: "test@example.com",
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "username"
        })

        account.custom_data["birth_date"] = "2305-07-13"

        created_account = directory.create_account account

        expect(created_account).to be
        expect(created_account.username).to eq(account.username)
        expect(created_account).to eq(account)
        expect(created_account.custom_data["birth_date"]).to eq("2305-07-13")
        created_account.delete
    end
  end

  describe '#create_group' do
    let(:directory) { test_directory }

    context 'given a valid group' do
      let(:group_name) { "valid_test_group" }

      let(:created_group) { directory.groups.create name: group_name }

      after do
        created_group.delete if created_group
      end

      it 'creates a group' do
        expect(created_group).to be
        expect(created_group.name).to eq(group_name)
      end
    end
  end

  describe '#delete_directory' do

    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:application) { test_api_client.applications.create name: 'test_application' }

    let!(:group) { directory.groups.create name: 'someGroup' }

    let!(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

    let!(:account_store_mapping) do
      test_api_client.account_store_mappings.create({ application: application, account_store: directory })
    end

    after do
      application.delete if application
    end

    it 'and all of its associations' do
      expect(directory.groups).to have(1).item
      expect(directory.accounts).to have(1).item

      expect(application.account_store_mappings.first.account_store).to eq(directory)

      expect(application.accounts).to include(account)
      expect(application.groups).to include(group)

      expect(application.account_store_mappings).to have(1).item

      directory.delete

      expect(application.account_store_mappings).to have(0).item

      expect(application.accounts).not_to include(account)
      expect(application.groups).not_to include(group)
    end

  end


end
