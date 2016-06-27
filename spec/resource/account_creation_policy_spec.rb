require 'spec_helper'

describe Stormpath::Resource::AccountCreationPolicy, :vcr do
  describe "instances should respond to attribute property methods" do
    let(:application) { test_application }
    let(:directory) { test_api_client.directories.create(name: random_directory_name) }
    let(:account_creation_policy) { directory.account_creation_policy }

    before do
      test_api_client.account_store_mappings.create(
        application: application,
        account_store: directory,
        list_index: 1,
        is_default_account_store: false,
        is_default_group_store: false
      )
    end

    after { directory.delete }

    it do
      expect(account_creation_policy).to be_a Stormpath::Resource::AccountCreationPolicy

      [:welcome_email_status,
       :verification_email_status,
       :verification_success_email_status].each do |property_accessor|
        expect(account_creation_policy).to respond_to(property_accessor)
        expect(account_creation_policy).to respond_to("#{property_accessor}=")
      end

      expect(account_creation_policy.verification_email_templates).to be_a Stormpath::Resource::Collection
      expect(account_creation_policy.verification_success_email_templates).to be_a Stormpath::Resource::Collection
      expect(account_creation_policy.welcome_email_templates).to be_a Stormpath::Resource::Collection

      expect(account_creation_policy.verification_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
      expect(account_creation_policy.verification_success_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
      expect(account_creation_policy.welcome_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
    end

    it 'can change welcome_email_status' do
      expect(directory.account_creation_policy.welcome_email_status).to eq('DISABLED')
      account_creation_policy.welcome_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.welcome_email_status).to eq('ENABLED')
    end

    it 'can change verification_email_status' do
      expect(directory.account_creation_policy.verification_email_status).to eq('DISABLED')
      account_creation_policy.verification_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.verification_email_status).to eq('ENABLED')
    end

    it 'can change verification_success_email_status' do
      expect(directory.account_creation_policy.verification_success_email_status).to eq('DISABLED')
      account_creation_policy.verification_success_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.verification_success_email_status).to eq('ENABLED')
    end
  end
end
