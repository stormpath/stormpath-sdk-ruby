require 'spec_helper'

describe Stormpath::Resource::Challenge, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(build_directory) }
    let(:account) { directory.accounts.create(build_account) }

    let(:factor) do
      account.factors.create(
        type: 'SMS',
        phone: {
          number: '2025550173',
          name: 'test phone',
          description: 'this is a testing phone number'
        }
      )
    end

    let(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

    after do
      factor.delete if factor
      account.delete if account
      directory.delete if directory
    end

    it do
      [:message].each do |property_accessor|
        expect(challenge).to respond_to(property_accessor)
        expect(challenge).to respond_to("#{property_accessor}=")
        expect(challenge.send(property_accessor)).to be_a String
      end

      [:status, :created_at, :modified_at].each do |property_getter|
        expect(challenge).to respond_to(property_getter)
        expect(challenge.send(property_getter)).to be_a String
      end

      expect(challenge.factor).to be_a Stormpath::Resource::Factor
      expect(challenge.account).to be_a Stormpath::Resource::Account
    end
  end

  describe 'challenge associations' do
    let(:app) { test_api_client.applications.create(build_application) }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create(build_directory) }

    before { map_account_store(app, directory, 1, true, true) }

    let(:account) { directory.accounts.create(build_account) }
    let(:phone_number) { '2025550173' }

    let(:factor) do
      account.factors.create(
        type: 'SMS',
        phone: {
          number: phone_number,
          name: 'test phone',
          description: 'this is a testing phone number'
        }
      )
    end

    let(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

    it 'should belong_to factor' do
      expect(challenge.factor).to eq(factor)
    end

    it 'should belong_to account' do
      expect(challenge.account).to eq(account)
    end

    after do
      application.delete if application
      account.delete if account
      directory.delete if directory
      factor.delete if factor
    end
  end
end
