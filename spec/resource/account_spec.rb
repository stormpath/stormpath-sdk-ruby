require 'spec_helper'

describe Stormpath::Resource::Account, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:account) do
      directory.accounts.create(account_attrs(email: 'ruby',
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
      expect(account.phones).to be_a Stormpath::Resource::Collection
      expect(account.factors).to be_a Stormpath::Resource::Collection
    end
  end

  describe 'account_associations' do
    let(:application) { test_api_client.applications.create(application_attrs) }
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:account) { directory.accounts.create(account_attrs) }
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
      let(:directory2) { test_api_client.directories.create(directory_attrs) }
      before do
        map_account_store(application, directory2, 2, false, false)
        account
      end

      after { directory2.delete }

      let!(:account2) { directory2.accounts.create(account_attrs) }
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
      let(:directory) { test_api_client.directories.create(directory_attrs) }
      let(:group) { directory.groups.create(group_attrs) }
      let(:account) { directory.accounts.create(account_attrs) }
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

  describe 'managing phones' do
    let(:application) { test_api_client.applications.create(application_attrs) }
    let(:directory) { test_api_client.directories.create(directory_attrs) }

    before do
      map_account_store(application, directory, 1, true, true)
      phone
    end

    let(:account) { directory.accounts.create(account_attrs) }
    let(:phone) do
      account.phones.create(
        number: '+12025550173',
        name: 'test phone',
        description: 'this is a testing phone number'
      )
    end

    it 'can fetch phones' do
      expect(account.phones).to include(phone)
    end

    it 'can fetch a specific phone' do
      expect(account.phones.get(phone.href)).to be_a Stormpath::Resource::Phone
    end

    it 'raises error if phone with same number created' do
      expect do
        account.phones.create(
          number: '+12025550173',
          name: 'test duplicate phone'
        )
      end.to raise_error(Stormpath::Error, 'An existing phone with that number already exists for this Account.')
    end

    after do
      application.delete if application
      directory.delete if directory
      account.delete if account
    end
  end

  describe 'managing factors' do
    let(:application) { test_api_client.applications.create(application_attrs) }
    let(:directory) { test_api_client.directories.create(directory_attrs) }

    before { map_account_store(application, directory, 1, true, true) }

    let(:account) { directory.accounts.create(account_attrs) }

    context 'sms type' do
      let!(:factor) do
        account.factors.create(
          type: 'SMS',
          phone: {
            number: '+12025550173',
            name: 'test phone',
            description: 'this is a testing phone number'
          }
        )
      end

      it 'can fetch factors' do
        expect(account.factors).to include(factor)
      end

      it 'can fetch a specific factor' do
        expect(account.factors.get(factor.href)).to be_a Stormpath::Resource::Factor
      end

      it 'creates a phone with a factor' do
        expect(account.phones.count).to eq 1
      end
    end

    context 'google-authenticator type' do
      let!(:factor) do
        account.factors.create(
          type: 'google-authenticator',
          account_name: "marko.cilimkovic#{default_domain}",
          issuer: 'ACME',
          status: 'ENABLED'
        )
      end

      it 'can fetch factors' do
        expect(account.factors).to include(factor)
      end
    end

    after do
      directory.delete if directory
      application.delete if application
    end
  end

  describe '#create_factor' do
    let(:application) { test_api_client.applications.create(application_attrs) }
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:account) { directory.accounts.create(account_attrs) }
    before { map_account_store(application, directory, 1, true, true) }

    context 'type sms' do
      before do
        stub_request(:post, "#{account.href}/factors?challenge=true")
          .to_return(body: Stormpath::Test.mocked_factor_response)
      end

      let(:factor) do
        account.create_factor(:sms,
                              phone: { number: '+12025550173',
                                       name: 'Rspec test phone',
                                       description: 'This is a testing phone number' },
                              challenge: { message: 'Enter code please: ' })
      end

      it 'factor should be created' do
        expect(factor).to be_kind_of Stormpath::Resource::Factor
      end
    end

    context 'type google-authenticator' do
      let(:factor) { account.create_factor(:google_authenticator, options) }

      context 'with account_name' do
        let(:account_name) { "marko.cilimkovic#{default_domain}" }
        let(:options) do
          {
            custom_options: {
              account_name: account_name,
              issuer: 'ACME',
              status: 'ENABLED'
            }
          }
        end

        it 'should create factor with custom account_name' do
          expect(factor.account_name).to eq account_name
        end
      end

      context 'with account_name not set' do
        let(:options) do
          {
            custom_options: {
              issuer: 'ACME',
              status: 'ENABLED'
            }
          }
        end

        it 'should create factor with account_name set to username' do
          expect(factor.account_name).to eq account.username
        end
      end

      context 'without custom options' do
        let(:options) { {} }
        it 'should create factor with account_name set to username' do
          expect(factor.account_name).to eq account.username
        end
      end
    end

    context 'with bad type set' do
      let(:factor) { account.create_factor(:invalid_type) }

      it 'should raise error' do
        expect { factor }.to raise_error(Stormpath::Error)
      end
    end

    after do
      directory.delete if directory
      application.delete if application
    end
  end

  describe '#save' do
    context 'when property values have changed' do
      let(:directory) { test_api_client.directories.create(directory_attrs) }
      let(:account) { directory.accounts.create(account_attrs) }
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
