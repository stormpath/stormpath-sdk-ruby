require 'spec_helper'

describe Stormpath::Resource::LinkedAccount, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory1) { test_api_client.directories.create(directory_attrs) }
  let(:directory2) { test_api_client.directories.create(directory_attrs) }
  let(:username_1) { "jekyll-#{random_number}" }
  let(:username_2) { "hyde-#{random_number}" }
  let(:account1) do
    directory1.accounts.create(account_attrs(email: username_1, username: username_1))
  end
  let(:account2) do
    directory2.accounts.create(account_attrs(email: username_2, username: username_2))
  end

  before do
    map_account_store(application, directory1, 1, true, false)
    map_account_store(application, directory2, 2, false, false)

    test_api_client.account_links.create(
      left_account: {
        href: account1.href
      },
      right_account: {
        href: account2.href
      }
    )
  end

  let(:linked_account) { account1.linked_accounts.first }

  after do
    application.delete
    directory1.delete
    directory2.delete
  end

  describe 'account link associations' do
    it 'should belong_to account' do
      expect(linked_account).to eq account2
    end
  end
end
