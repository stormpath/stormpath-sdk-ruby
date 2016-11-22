require 'spec_helper'

describe 'BasicAuthenticator', vcr: true do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:organization) { test_api_client.organizations.create(organization_attrs) }
  let(:authenticator) do
    Stormpath::Authentication::BasicAuthenticator.new(test_api_client.data_store)
  end
  let(:dir_account) do
    directory.accounts.create(account_attrs(username: 'ruby_cilim_dir', password: 'F00barfoo'))
  end
  let(:org_account) do
    organization.accounts.create(account_attrs(username: 'ruby_cilim_org', password: 'F00barfoo'))
  end
  let(:request) do
    Stormpath::Authentication::UsernamePasswordRequest.new(dir_account.username, 'F00barfoo')
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

  context 'authenticate without account store' do
    let(:account) { dir_account }
    it_should_behave_like 'an AuthenticationResult'
  end

  context 'authenticate with account store' do
    let(:account) { org_account }
    let(:request) do
      Stormpath::Authentication::UsernamePasswordRequest.new(org_account.username,
                                                             'F00barfoo',
                                                             account_store: organization)
    end

    it_should_behave_like 'an AuthenticationResult'
  end
end
