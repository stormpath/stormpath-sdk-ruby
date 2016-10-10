require 'spec_helper'

describe Stormpath::Resource::Factor, :vcr do
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

    after do
      factor.delete if factor
      account.delete if account
      directory.delete if directory
    end

    it do
      [:type].each do |property_accessor|
        expect(factor).to respond_to(property_accessor)
        expect(factor).to respond_to("#{property_accessor}=")
        expect(factor.send(property_accessor)).to be_a String
      end

      [:verification_status, :status].each do |property_getter|
        expect(factor).to respond_to(property_getter)
        expect(factor.send(property_getter)).to be_a String
      end

      expect(factor.account).to be_a Stormpath::Resource::Account
      expect(factor.phone).to be_a Stormpath::Resource::Phone
      expect(factor.challenges).to be_a Stormpath::Resource::Collection
    end
  end

  describe 'factor associations' do
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

    it 'should belong_to account' do
      expect(factor.account).to eq(account)
    end

    it 'should have one phone' do
      expect(factor.phone.number).to eq(phone_number)
    end

    context 'challenges' do
      let(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

      before do
        challenge
      end

      it 'should have a collection of challenges' do
        expect(factor.challenges).to be_a Stormpath::Resource::Collection
        expect(factor.challenges).to include(challenge)
      end

      it 'should have the most recent challenge' do
        most_recent_challenge = factor.challenges.create(message: 'Enter new code: ${code}')
        reloaded_factor = account.factors.get(factor.href)
        expect(reloaded_factor.most_recent_challenge).to eq(most_recent_challenge)
      end
    end

    after do
      application.delete if application
      account.delete if account
      directory.delete if directory
      factor.delete if factor
    end
  end
end
