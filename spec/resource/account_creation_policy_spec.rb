require 'spec_helper'

describe Stormpath::Resource::AccountCreationPolicy, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:application) { test_application }
    let(:directory) { test_api_client.directories.create(name: random_directory_name) }
    let(:account_creation_policy) { directory.account_creation_policy }
    let(:create_valid_account) do
      directory.accounts.create(
        username: 'cilim',
        email: 'cilim@infinum.co',
        given_name: 'Marko',
        surname: 'Cilimkovic',
        password: 'wonderfulWeatherIsntIt2'
      )
    end
    let(:create_invalid_account) do
      directory.accounts.create(
        username: 'cilim',
        email: 'cilim@infinum.hr',
        given_name: 'Marko',
        surname: 'Cilimkovic',
        password: 'wonderfulWeatherIsntIt2'
      )
    end

    before do
      test_api_client.account_store_mappings.create(
        application: application,
        account_store: directory,
        list_index: 1,
        is_default_account_store: false,
        is_default_group_store: false
      )
    end

    after { directory.delete }

    it do
      expect(account_creation_policy).to be_a Stormpath::Resource::AccountCreationPolicy

      [:welcome_email_status,
       :verification_email_status,
       :verification_success_email_status,
       :email_domain_whitelist,
       :email_domain_blacklist].each do |property_accessor|
        expect(account_creation_policy).to respond_to(property_accessor)
        expect(account_creation_policy).to respond_to("#{property_accessor}=")
      end

      expect(account_creation_policy.verification_email_templates).to be_a Stormpath::Resource::Collection
      expect(account_creation_policy.verification_success_email_templates).to be_a Stormpath::Resource::Collection
      expect(account_creation_policy.welcome_email_templates).to be_a Stormpath::Resource::Collection

      expect(account_creation_policy.verification_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
      expect(account_creation_policy.verification_success_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
      expect(account_creation_policy.welcome_email_templates.first).to be_a Stormpath::Resource::EmailTemplate
    end

    it 'can change welcome_email_status' do
      expect(directory.account_creation_policy.welcome_email_status).to eq('DISABLED')
      account_creation_policy.welcome_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.welcome_email_status).to eq('ENABLED')
    end

    it 'can change verification_email_status' do
      expect(directory.account_creation_policy.verification_email_status).to eq('DISABLED')
      account_creation_policy.verification_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.verification_email_status).to eq('ENABLED')
    end

    it 'can change verification_success_email_status' do
      expect(directory.account_creation_policy.verification_success_email_status).to eq('DISABLED')
      account_creation_policy.verification_success_email_status = 'ENABLED'
      account_creation_policy.save
      expect(directory.account_creation_policy.verification_success_email_status).to eq('ENABLED')
    end

    it 'can change whitelisted email domains' do
      whitelisted = ['*infinum.co', '*infinum.hr']
      account_creation_policy.email_domain_whitelist = whitelisted
      account_creation_policy.save
      expect(directory.account_creation_policy.email_domain_whitelist).to eq whitelisted

      account_creation_policy.email_domain_whitelist = ['*infinum.hr']
      account_creation_policy.save
      expect(directory.account_creation_policy.email_domain_whitelist).to include '*infinum.hr'
      expect(directory.account_creation_policy.email_domain_whitelist).not_to include '*infinum.co'
    end

    it 'can change blacklisted email domains' do
      blacklisted = ['*spam.com', '*e1ppe.ro']
      account_creation_policy.email_domain_blacklist = blacklisted
      account_creation_policy.save
      expect(directory.account_creation_policy.email_domain_blacklist).to eq blacklisted

      account_creation_policy.email_domain_blacklist = ['*spam.com']
      account_creation_policy.save
      expect(directory.account_creation_policy.email_domain_blacklist).to include '*spam.com'
      expect(directory.account_creation_policy.email_domain_blacklist).not_to include '*e1ppe.ro'
    end

    describe 'adding and removing from whitelist' do
      before do
        whitelisted = ['*infinum.co', '*infinum.hr']
        account_creation_policy.email_domain_whitelist = whitelisted
        account_creation_policy.save
      end

      context 'add to whitelist' do
        it 'should add to whitelist' do
          account_creation_policy.add_to_whitelist('*stormpath.com')
          expect(directory.account_creation_policy.email_domain_whitelist).to include '*stormpath.com'
          expect(directory.account_creation_policy.email_domain_whitelist.count).to eq 3

          account_creation_policy.add_to_whitelist('*gmail.com', '*hotmail.com')
          expect(directory.account_creation_policy.email_domain_whitelist.count).to eq 5
        end

        it 'should throw error if no emails present' do
          expect do
            account_creation_policy.add_to_whitelist
          end.to raise_error(ArgumentError, "emails can't be blank when add_to whitelist")
        end
      end

      context 'remove from whitelist' do
        it 'should remove from whitelist' do
          account_creation_policy.remove_from_whitelist('*infinum.hr')
          expect(directory.account_creation_policy.email_domain_whitelist).not_to include '*infinum.hr'
          expect(directory.account_creation_policy.email_domain_whitelist.count).to eq 1
        end
      end
    end

    describe 'adding and removing from blacklist' do
      before do
        blacklist = ['*infinum.co', '*infinum.hr']
        account_creation_policy.email_domain_blacklist = blacklist
        account_creation_policy.save
      end

      context 'add to blacklist' do
        it 'should add to blacklist' do
          account_creation_policy.add_to_blacklist('*stormpath.com')
          expect(directory.account_creation_policy.email_domain_blacklist).to include '*stormpath.com'
          expect(directory.account_creation_policy.email_domain_blacklist.count).to eq 3

          account_creation_policy.add_to_blacklist('*gmail.com', '*hotmail.com')
          expect(directory.account_creation_policy.email_domain_blacklist.count).to eq 5
        end
      end

      context 'remove from blacklist' do
        it 'should remove from blacklist' do
          account_creation_policy.remove_from_blacklist('*infinum.hr')
          expect(directory.account_creation_policy.email_domain_blacklist).not_to include '*infinum.hr'
          expect(directory.account_creation_policy.email_domain_blacklist.count).to eq 1
        end
      end
    end

    context 'when domain not string' do
      it 'should raise error' do
        blacklisted = ['*spam.com', 12345]
        account_creation_policy.email_domain_blacklist = blacklisted
        expect do
          account_creation_policy.save
        end.to raise_error(Stormpath::Error, /is an invalid type./)
      end
    end

    context 'when domain invalid' do
      it 'should raise error' do
        blacklisted = ['*spam.com', '*youre@jiberish']
        account_creation_policy.email_domain_blacklist = blacklisted
        expect do
          account_creation_policy.save
        end.to raise_error(Stormpath::Error, /It is not a valid domain./)
      end
    end

    describe 'create account' do
      context 'when whitelisted domains exist' do
        before do
          whitelisted = ['*infinum.co']
          account_creation_policy.email_domain_whitelist = whitelisted
          account_creation_policy.save
        end

        context 'when account whitelisted' do
          it 'should successfully create the account' do
            account = create_valid_account
            expect(account).to be_a Stormpath::Resource::Account
            expect(account.username).to eq('cilim')
          end
        end

        context 'when account not whitelisted' do
          it 'should raise error' do
            expect do
              create_invalid_account
            end.to raise_error(Stormpath::Error, "Cannot create the Account because your email's domain is not allowed.")
          end
        end
      end

      context 'when blacklisted domains exist' do
        context 'when account email blacklisted' do
          it 'should not create the account' do
            blacklisted = ['*spam.com']
            account_creation_policy.email_domain_blacklist = blacklisted
            account_creation_policy.save

            expect do
              @account = directory.accounts.create(
                username: 'cilim',
                email: 'cilim@spam.com',
                given_name: 'Marko',
                surname: 'Cilimkovic',
                password: 'wonderfulWeatherIsntIt2'
              )
            end.to raise_error(Stormpath::Error, "Cannot create the Account because your email's domain is not allowed.")
          end
        end
      end

      context 'when account email in blacklisted and whitelisted domains' do
        it 'should not create the account' do
          bothlisted = ['*infinum.hr']
          account_creation_policy.email_domain_blacklist = bothlisted
          account_creation_policy.email_domain_whitelist = bothlisted
          account_creation_policy.save

          expect do
            create_invalid_account
          end.to raise_error(Stormpath::Error, "Cannot create the Account because your email's domain is not allowed.")
        end
      end
    end
  end
end
