require 'spec_helper'

describe Stormpath::Resource::EmailTemplate, :vcr do
  describe "instances should respond to attribute property methods" do
    let(:application) { test_application }
    let(:directory) { test_api_client.directories.create(name: random_directory_name) }
    let(:password_policy) { directory.password_policy }
    let(:reset_email_template) { password_policy.reset_email_templates.first }

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
      expect(reset_email_template).to be_a Stormpath::Resource::EmailTemplate

      [:name,
       :description,
       :subject,
       :from_email_address,
       :text_body,
       :html_body,
       :mime_type].each do |property_accessor|
        expect(reset_email_template).to respond_to(property_accessor)
        expect(reset_email_template).to respond_to("#{property_accessor}=")
      end
    end

    it 'can change attributes' do
      reset_email_template.name = "Default Password Reset Template"
      reset_email_template.description = "This is the password reset email template"
      reset_email_template.subject = "Please reset your password"
      reset_email_template.from_email_address = "email@stormpath.com"
      reset_email_template.text_body = "You forgot your password! ${sptoken}"
      reset_email_template.html_body = "<p> You forgot your password! </p> ${sptoken}"
      reset_email_template.mime_type = "text/plain"

      reset_email_template.save

      reloaded_reset_email_template = password_policy.reset_email_templates.first

      expect(reloaded_reset_email_template.name).to eq("Default Password Reset Template")
      expect(reloaded_reset_email_template.description).to eq("This is the password reset email template")
      expect(reloaded_reset_email_template.subject).to eq("Please reset your password")
      expect(reloaded_reset_email_template.from_email_address).to eq("email@stormpath.com")
      expect(reloaded_reset_email_template.text_body).to eq("You forgot your password! ${sptoken}")
      expect(reloaded_reset_email_template.html_body).to eq("<p> You forgot your password! </p> ${sptoken}")
      expect(reloaded_reset_email_template.mime_type).to eq("text/plain")
    end
  end
end
