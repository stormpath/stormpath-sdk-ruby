require 'spec_helper'

describe Stormpath::Resource::AccountLink, :vcr do
  let(:application) do
    test_api_client.applications.create(name: 'ruby sdk app', description: 'ruby sdk desc')
  end
  let(:good_dir) do
    test_api_client.directories.create(name: 'ruby sdk dir 1')
  end
  let(:bad_dir) do
    test_api_client.directories.create(name: 'ruby sdk dir 2')
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
  end

  let!(:dr_jekyll) do
    good_dir.accounts.create(build_account(email: 'jekyll@example.com', username: 'dr_jekyll'))
  end
  let!(:mr_hyde) do
    bad_dir.accounts.create(build_account(email: 'hyde@example.com', username: 'mr_hyde'))
  end

  let!(:account_link) do
    test_api_client.account_links.create(
      left_account: {
        href: dr_jekyll.href
      },
      right_account: {
        href: mr_hyde.href
      }
    )
  end

  after do
    application.delete
    good_dir.delete
    bad_dir.delete
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
      expect(account_link.right_account).to eq(mr_hyde)
    end

    it 'should belong_to left account' do
      expect(account_link.left_account).to eq(dr_jekyll)
    end
  end
end
