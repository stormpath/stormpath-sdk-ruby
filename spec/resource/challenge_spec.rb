require 'spec_helper'

describe Stormpath::Resource::Challenge, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create name: random_directory_name }
    let(:account) do
      directory.accounts.create(email: 'test@example.com',
                                given_name: 'Ruby SDK',
                                password: 'P@$$w0rd',
                                surname: 'SDK',
                                username: 'rubysdk')
    end
    let(:factor) do
      account.factors.create(
        type: 'SMS',
        phone: {
          number: '+385958142457',
          name: 'Markos test phone',
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
    let(:app) do
      test_api_client.applications.create(name: random_application_name, description: 'Dummy desc.')
    end
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create name: random_directory_name }

    before do
      test_api_client.account_store_mappings.create(application: app,
                                                    account_store: directory,
                                                    list_index: 1,
                                                    is_default_account_store: true,
                                                    is_default_group_store: true)
    end

    let(:account) do
      directory.accounts.create(email: 'test@example.com',
                                givenName: 'Ruby SDK',
                                password: 'P@$$w0rd',
                                surname: 'SDK',
                                username: 'rubysdk')
    end
    let(:phone_number) { '+385958142457' }

    let(:factor) do
      account.factors.create(
        type: 'SMS',
        phone: {
          number: phone_number,
          name: 'Markos test phone',
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
