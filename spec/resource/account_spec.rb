require 'spec_helper'

describe Stormpath::Resource::Account, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(build_directory) }
    let(:account) do
      directory.accounts.create(build_account(email: 'ruby',
                                              given_name: 'ruby',
                                              surname: 'ruby',
                                              middle_name: 'ruby'))
    end

    after do
      account.delete
      directory.delete
    end

    it do
      [:given_name, :username, :middle_name, :surname, :email, :status].each do |property_accessor|
        expect(account).to respond_to(property_accessor)
        expect(account).to respond_to("#{property_accessor}=")
        expect(account.send(property_accessor)).to be_a String
      end

      [:created_at, :modified_at, :password_modified_at].each do |property_getter|
        expect(account).to respond_to(property_getter)
        expect(account.send(property_getter)).to be_a String
      end

      expect(account).to respond_to(:full_name)
      expect(account.full_name).to be_a String
      expect(account.full_name).to eq('ruby ruby ruby')
      expect(account).to respond_to('password=')

      expect(account.tenant).to be_a Stormpath::Resource::Tenant
      expect(account.directory).to be_a Stormpath::Resource::Directory
      expect(account.custom_data).to be_a Stormpath::Resource::CustomData
      expect(account.email_verification_token).to be_nil
      expect(account.groups).to be_a Stormpath::Resource::Collection
      expect(account.group_memberships).to be_a Stormpath::Resource::Collection
      expect(account.applications).to be_a Stormpath::Resource::Collection
    end
  end

  describe 'account_associations' do
    let(:application) { test_api_client.applications.create(build_application) }
    let(:directory) { test_api_client.directories.create(build_directory) }
    let(:account) { directory.accounts.create(build_account) }
    before { map_account_store(application, directory, 1, true, true) }

    it 'should belong_to directory' do
      expect(account.directory).to eq(directory)
    end

    it 'should have many applications' do
      expect(account.applications.count).to eq(1)
    end

    it 'should belong_to tenant' do
      expect(account.tenant).to be
      expect(account.tenant).to eq(account.directory.tenant)
    end

    describe 'linked accounts' do
      let(:directory2) { test_api_client.directories.create(build_directory) }
      before do
        map_account_store(application, directory2, 2, false, false)
        account
      end

      after { directory2.delete }

      let!(:account2) { directory2.accounts.create(build_account) }
      let!(:link_accounts) do
        test_api_client.account_links.create(
          left_account: {
            href: account.href
          },
          right_account: {
            href: account2.href
          }
        )
      end

      it 'should contain 1 linked account' do
        expect(account.linked_accounts.count).to eq 1
        expect(account.linked_accounts.first).to eq account2
      end
    end

    after do
      application.delete if application
      account.delete if account
      directory.delete if directory
    end
  end

  describe '#add_or_remove_group' do
    context 'given a group' do
      let(:directory) { test_api_client.directories.create(build_directory) }
      let(:group) { directory.groups.create(build_group) }
      let(:account) { directory.accounts.create(build_account) }
      before { account.add_group(group) }

      after do
        account.delete
        group.delete
        directory.delete
      end

      it 'adds the group to the account' do
        expect(account.groups).to include(group)
      end

      it 'has one group membership resource' do
        expect(account.group_memberships.count).to eq(1)
      end

      it 'adds and removes the group from the account' do
        expect(account.groups).to include(group)

        account.remove_group group

        expect(account.groups).not_to include(group)
      end
    end
  end

  describe '#save' do
    context 'when property values have changed' do
      let(:directory) { test_api_client.directories.create(build_directory) }
      let(:account) { directory.accounts.create(build_account) }
      let(:account_uri) { account.href }
      let(:new_surname) { 'NewSurname' }
      let(:reloaded_account) { test_api_client.accounts.get(account_uri) }

      before do
        account = test_api_client.accounts.get(account_uri)
        account.surname = new_surname
        account.save
      end

      after do
        account.delete
        directory.delete
      end

      it 'saves changes to the account' do
        expect(reloaded_account.surname).to eq(new_surname)
      end
    end
  end
end
