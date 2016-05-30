require 'spec_helper'

describe Stormpath::Resource::PasswordStrength, :vcr do
  describe "instances should respond to attribute property methods" do
    let(:application) { test_application }
    let(:directory) { test_api_client.directories.create(name: random_directory_name) }
    let(:password_policy) { directory.password_policy }
    let(:password_strength) { password_policy.strength }

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
      expect(password_policy.strength.min_length).to eq(8)
      password_strength.min_length = 10
      password_strength.save
      expect(password_policy.strength.min_length).to eq(10)
    end
  end
end
