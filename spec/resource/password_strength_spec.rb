require 'spec_helper'

describe Stormpath::Resource::PasswordPolicy, :vcr do
  describe "instances should respond to attribute property methods" do
    let(:application) { test_application }
    let(:directory) { test_api_client.directories.create(name: random_directory_name) }
    let(:password_policy) { directory.password_policy }
    let(:password_strength) { directory.password_strength }

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
      expect(password_strength).to be_a Stormpath::Resource::PasswordStrength

      [ :min_length,
        :max_length,
        :min_lower_case,
        :min_upper_case,
        :min_numeric,
        :min_symbol,
        :min_diacritic,
        :prevent_reuse].each do |property_accessor|
        expect(password_strength).to respond_to(property_accessor)
        expect(password_strength).to respond_to("#{property_accessor}=")
      end
    end

    it 'can change reset_token_ttl' do
      expect(directory.password_policy.reset_token_ttl).to eq(24)
      password_policy.reset_token_ttl = 10
      password_policy.save
      expect(directory.password_policy.reset_token_ttl).to eq(10)
    end
  end
end
