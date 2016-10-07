require 'spec_helper'

describe Stormpath::Resource::Phone, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create name: random_directory_name }
    let(:account) do
      directory.accounts.create(email: 'test@example.com',
                                given_name: 'Ruby SDK',
                                password: 'P@$$w0rd',
                                surname: 'SDK',
                                username: 'rubysdk')
    end
    let(:phone) do
      account.phones.create(
        number: '+385958142457',
        name: 'Markos test phone',
        description: 'this is a testing phone number'
      )
    end

    after do
      phone.delete if phone
      account.delete if account
      directory.delete if directory
    end

    it do
      [:number, :name, :description].each do |property_accessor|
        expect(phone).to respond_to(property_accessor)
        expect(phone).to respond_to("#{property_accessor}=")
        expect(phone.send(property_accessor)).to be_a String
      end

      [:verification_status, :status, :created_at, :modified_at].each do |property_getter|
        expect(phone).to respond_to(property_getter)
        expect(phone.send(property_getter)).to be_a String
      end

      expect(phone.account).to be_a Stormpath::Resource::Account
    end
  end

  describe 'account_associations' do
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

    let(:phone) do
      account.phones.create(
        number: '+385958142457',
        name: 'Markos test phone',
        description: 'this is a testing phone number'
      )
    end

    it 'should belong_to account' do
      expect(phone.account).to eq(account)
    end

    after do
      application.delete if application
      account.delete if account
      directory.delete if directory
      phone.delete if phone
    end
  end
end
