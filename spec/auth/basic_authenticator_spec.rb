require 'spec_helper'

describe 'BasicAuthenticator', vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:directory2) { test_api_client.directories.create(directory_attrs) }
  let(:organization) { test_api_client.organizations.create(organization_attrs) }
  let(:authenticator) do
    Stormpath::Authentication::BasicAuthenticator.new(test_api_client.data_store)
  end
  let(:password) { 'F00barfoo' }
  let(:invalid_password) { 'Wr00ngPassw0rd' }
  let(:dir_account) do
    directory.accounts.create(account_attrs(username: 'ruby_cilim_dir', password: password))
  end
  let(:org_account) do
    organization.accounts.create(account_attrs(username: 'ruby_cilim_org', password: password))
  end
  let(:request) do
    Stormpath::Authentication::UsernamePasswordRequest.new(account.username,
                                                           password,
                                                           account_store: account_store)
  end
  let(:authenticate) { authenticator.authenticate(application.href, request) }

  before do
    map_account_store(application, directory, 0, true, true)
    map_account_store(application, organization, 1, false, false)
    map_organization_store(directory, organization, true)
  end

  after do
    application.delete
    directory.delete
    organization.delete
  end

  shared_examples 'an AuthenticationResult' do
    it 'is an AuthenticationResult' do
      expect(authenticate).to be_kind_of Stormpath::Authentication::AuthenticationResult
    end

    it 'has an account' do
      expect(authenticate.account.email).to eq account.email
    end
  end

  shared_examples 'an invalid username or password error' do
    it 'raises a Stormpath::Error' do
      expect { authenticate }.to raise_error(Stormpath::Error, 'Invalid username or password.')
    end
  end

  context 'authenticate without account store' do
    let(:account) { dir_account }
    let(:account_store) { nil }

    context 'successful authentication' do
      it_should_behave_like 'an AuthenticationResult'
    end

    context 'wrong password' do
      let(:request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(org_account.username,
                                                               invalid_password)
      end

      it_behaves_like 'an invalid username or password error'
    end
  end

  context 'authenticate with account store' do
    let(:account) { org_account }
    let(:account_store) { organization }

    context 'successful authentication' do
      let(:request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(org_account.username,
                                                               password,
                                                               account_store: organization)
      end

      it_should_behave_like 'an AuthenticationResult'
    end

    context 'wrong password' do
      let(:request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(org_account.username,
                                                               invalid_password,
                                                               account_store: organization)
      end

      it_behaves_like 'an invalid username or password error'
    end

    context 'account not in account store' do
      before { map_account_store(application, directory2, 1, false, false) }
      after { directory2.delete }

      let(:another_account) do
        directory2.accounts.create(account_attrs(username: 'ruby-dir-acc', password: password))
      end
      let(:request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(another_account.username,
                                                               password,
                                                               account_store: organization)
      end

      it_behaves_like 'an invalid username or password error'
    end
  end
end
