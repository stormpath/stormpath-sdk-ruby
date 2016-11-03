require 'spec_helper'

describe Stormpath::Resource::LinkedAccount, :vcr do
  let(:application) do
    test_api_client.applications.create(name: 'ruby sdk app', description: 'ruby sdk desc')
  end
  let(:good_dir) { test_api_client.directories.create(name: 'ruby sdk dir 1') }
  let(:bad_dir) { test_api_client.directories.create(name: 'ruby sdk dir 2') }
  let(:dr_jekyll) do
    good_dir.accounts.create(build_account(email: 'jekyll@example.com', username: 'dr_jekyll'))
  end
  let(:mr_hyde) do
    bad_dir.accounts.create(build_account(email: 'hyde@example.com', username: 'mr_hyde'))
  end

  before do
    test_api_client.account_store_mappings.create(
      application: application,
      account_store: good_dir,
      list_index: 1,
      is_default_account_store: true,
      is_default_group_store: false
    )

    test_api_client.account_store_mappings.create(
      application: application,
      account_store: bad_dir,
      list_index: 2,
      is_default_account_store: false,
      is_default_group_store: false
    )

    test_api_client.account_links.create(
      left_account: {
        href: dr_jekyll.href
      },
      right_account: {
        href: mr_hyde.href
      }
    )
  end

  let(:linked_account) { dr_jekyll.linked_accounts.first }

  after do
    application.delete
    good_dir.delete
    bad_dir.delete
  end

  describe 'account link associations' do
    it 'should belong_to account' do
      expect(linked_account).to eq mr_hyde
    end
  end
end
