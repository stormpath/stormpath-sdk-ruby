require 'spec_helper'

describe Stormpath::Resource::Directory, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

    it do
      expect(directory).to be_a Stormpath::Resource::Directory

      [:name, :description, :status].each do |property_accessor|
        expect(directory).to respond_to(property_accessor)
        expect(directory).to respond_to("#{property_accessor}=")
        expect(directory.send property_accessor).to be_a String
      end

      expect(directory.tenant).to be_a Stormpath::Resource::Tenant
      expect(directory.groups).to be_a Stormpath::Resource::Collection
      expect(directory.accounts).to be_a Stormpath::Resource::Collection
      expect(directory.custom_data).to be_a Stormpath::Resource::CustomData
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
      let(:group) { directory.groups.create name: random_group_name }

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
        email: random_email,
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: random_user_name
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
        expect(created_account.email_verification_token).not_to be
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
        expect(created_account_with_reg_workflow.email_verification_token).not_to be
      end
    end

  end

  describe '#create_directory_with_custom_data' do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

    it 'creates an directory with custom data' do
      directory.custom_data["category"] = "classified"

      directory.save
      expect(directory.name).to eq(random_directory_name)
      expect(directory.description).to eq('description_for_some_test_directory')
      expect(directory.custom_data["category"]).to eq("classified")
    end
  end

  describe '#create_account_with_custom_data' do
    let(:directory) { test_directory }

      it 'creates an account with custom data' do
        account =  Stormpath::Resource::Account.new({
          email: random_email,
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: random_user_name
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

    let(:directory) { test_api_client.directories.create name: random_directory_name }

    let(:application) { test_api_client.applications.create name: random_application_name }

    let!(:group) { directory.groups.create name: 'someGroup' }

    let!(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

    let!(:account_store_mapping) do
      test_api_client.account_store_mappings.create({ application: application, account_store: directory })
    end

    after do
      application.delete if application
    end

    it 'and all of its associations' do
      expect(directory.groups.count).to eq(1)
      expect(directory.accounts.count).to eq(1)

      expect(application.account_store_mappings.first.account_store).to eq(directory)

      expect(application.accounts).to include(account)
      expect(application.groups).to include(group)

      expect(application.account_store_mappings.count).to eq(1)

      directory.delete

      expect(application.account_store_mappings.count).to eq(0)

      expect(application.accounts).not_to include(account)
      expect(application.groups).not_to include(group)
    end

  end


end
