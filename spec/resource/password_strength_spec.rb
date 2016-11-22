require 'spec_helper'

describe Stormpath::Resource::PasswordStrength, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }

  after { application.delete }

  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:password_policy) { directory.password_policy }
    let(:password_strength) { password_policy.strength }

    before do
      map_account_store(application, directory, 1, false, false)
    end

    after { directory.delete }

    it do
      expect(password_strength).to be_a Stormpath::Resource::PasswordStrength

      [:min_length,
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
