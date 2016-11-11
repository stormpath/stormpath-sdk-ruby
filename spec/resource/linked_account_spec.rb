require 'spec_helper'

describe Stormpath::Resource::LinkedAccount, :vcr do
  let(:application) do
    test_api_client.applications.create(name: 'ruby sdk app', description: 'ruby sdk desc')
  end
  let(:directory1) { test_api_client.directories.create(name: 'ruby sdk dir 1') }
  let(:directory2) { test_api_client.directories.create(name: 'ruby sdk dir 2') }
  let(:account1) do
    directory1.accounts.create(build_account(email: 'jekyll', username: 'jekyll'))
  end
  let(:account2) do
    directory2.accounts.create(build_account(email: 'hyde', username: 'hyde'))
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
