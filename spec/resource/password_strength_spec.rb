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

    it 'can change attributes' do
      expect(password_policy.strength.min_length).to eq(8)
      expect(password_policy.strength.max_length).to eq(100)
      expect(password_policy.strength.min_lower_case).to eq(1)
      expect(password_policy.strength.min_upper_case).to eq(1)
      expect(password_policy.strength.min_numeric).to eq(1)
      expect(password_policy.strength.min_symbol).to eq(0)
      expect(password_policy.strength.min_diacritic).to eq(0)
      expect(password_policy.strength.prevent_reuse).to eq(0)

      password_strength.min_length = 10
      password_strength.max_length = 99
      password_strength.min_lower_case = 2
      password_strength.min_upper_case = 2
      password_strength.min_numeric = 2
      password_strength.min_symbol = 1
      password_strength.min_diacritic = 1
      password_strength.prevent_reuse = 1

      password_strength.save

      expect(password_policy.strength.min_length).to eq(10)
      expect(password_policy.strength.max_length).to eq(99)
      expect(password_policy.strength.min_lower_case).to eq(2)
      expect(password_policy.strength.min_upper_case).to eq(2)
      expect(password_policy.strength.min_numeric).to eq(2)
      expect(password_policy.strength.min_symbol).to eq(1)
      expect(password_policy.strength.min_diacritic).to eq(1)
      expect(password_policy.strength.prevent_reuse).to eq(1)
    end
  end
end
