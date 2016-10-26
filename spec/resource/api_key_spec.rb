require 'spec_helper'

describe Stormpath::Resource::ApiKey, :vcr do
  let(:application) do
    test_api_client.applications.create(name: random_application_name('ruby_api_key_spec'),
                                        description: 'Dummy desc.')
  end
  let(:directory) { test_api_client.directories.create(name: random_directory_name) }
  let(:tenant) { application.tenant }

  let(:account) do
    application.accounts.create(
      email: 'test@example.com',
      given_name: 'Ruby SDK',
      password: 'P@$$w0rd',
      surname: 'SDK'
    )
  end

  let(:api_key) { account.api_keys.create({}) }

  before do
    map_account_store(application, directory, 1, true, false)
  end

  after do
    application.delete
    directory.delete
    account.delete
  end

  describe 'instances should respond to attribute property methods' do
    it do
      [:name, :description, :status].each do |property_accessor|
        expect(api_key).to respond_to(property_accessor)
        expect(api_key).to respond_to("#{property_accessor}=")
      end

      [:id, :secret].each do |property_getter|
        expect(api_key).to respond_to(property_getter)
        expect(api_key.send(property_getter)).to be_a String
      end

      expect(api_key.tenant).to be_a Stormpath::Resource::Tenant
      expect(api_key.account).to be_a Stormpath::Resource::Account
    end
  end

  describe 'api_key_associations' do
    it 'should belong_to account' do
      expect(api_key.account).to eq(account)
    end

    it 'should belong_to tenant' do
      expect(api_key.tenant).to eq(tenant)
    end

    it 'apps can fetch api keys' do
      fetched_api_key = application.api_keys.search(id: api_key.id).first
      expect(fetched_api_key).to eq(api_key)
    end

    it 'accounts can fetch api keys' do
      api_key
      expect(account.api_keys.count).to eq(1)
    end
  end
end
