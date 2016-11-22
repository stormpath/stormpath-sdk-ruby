require 'spec_helper'

describe Stormpath::Resource::Phone, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:account) { directory.accounts.create(account_attrs) }
    let(:phone) do
      account.phones.create(
        number: '+12025550173',
        name: 'test phone',
        description: 'this is a testing phone number'
      )
    end

    after do
      phone.delete
      account.delete
      directory.delete
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

  describe 'phone associations' do
    let(:app) { test_api_client.applications.create(application_attrs) }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create(directory_attrs) }

    before { map_account_store(app, directory, 1, true, true) }
    let(:account) { directory.accounts.create(account_attrs) }
    let(:phone) do
      account.phones.create(
        number: '+12025550173',
        name: 'test phone',
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
