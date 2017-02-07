require 'spec_helper'

describe Stormpath::Resource::AccountLink, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory1) { test_api_client.directories.create(directory_attrs) }
  let(:directory2) { test_api_client.directories.create(directory_attrs) }
  let(:username1) { "jekyll-#{random_number}" }
  let(:username2) { "hyde-#{random_number}" }

  before do
    map_account_store(application, directory1, 1, true, false)
    map_account_store(application, directory2, 2, false, false)
  end

  let!(:account1) { directory1.accounts.create(account_attrs(email: username1, username: username1)) }
  let!(:account2) { directory2.accounts.create(account_attrs(email: username2, username: username2)) }

  let!(:account_link) do
    test_api_client.account_links.create(
      left_account: {
        href: account1.href
      },
      right_account: {
        href: account2.href
      }
    )
  end

  after do
    application.delete
    directory1.delete
    directory2.delete
  end

  describe 'instances should respond to attribute property methods' do
    it do
      [:left_account, :right_account].each do |property_accessor|
        expect(account_link).to respond_to(property_accessor)
        expect(account_link).to respond_to("#{property_accessor}=")
        expect(account_link.send(property_accessor)).to be_a Stormpath::Resource::Account
      end

      [:created_at, :modified_at].each do |property_getter|
        expect(account_link).to respond_to(property_getter)
        expect(account_link.send(property_getter)).to be_a String
      end

      expect(account_link.left_account).to be_a Stormpath::Resource::Account
      expect(account_link.right_account).to be_a Stormpath::Resource::Account
    end
  end

  describe 'account link associations' do
    it 'should belong_to right account' do
      expect(account_link.right_account).to eq(account2)
    end

    it 'should belong_to left account' do
      expect(account_link.left_account).to eq(account1)
    end
  end
end
