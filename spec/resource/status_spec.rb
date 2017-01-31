require 'spec_helper'

describe 'StatusOnDirectoryAndAccount', :vcr do
  let(:auth_request) do
    Stormpath::Authentication::UsernamePasswordRequest.new("rubytest#{default_domain}", 'P@$$w0rd')
  end
  let(:authenticate_user) do
    application.authenticate_account(auth_request)
  end
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:group) { directory.groups.create(group_attrs) }
  let!(:account) do
    directory.accounts.create(account_attrs(email: 'rubytest', password: 'P@$$w0rd'))
  end
  let(:reloaded_account) { test_api_client.accounts.get(account.href) }
  before { map_account_store(application, directory, 0, true, true) }

  after do
    application.delete if application
    directory.delete if directory
  end

  it 'should respond to status getter and setter' do
    expect(directory.respond_to?(:status)).to be_truthy
    expect(directory.respond_to?(:status=)).to be_truthy

    expect(application.respond_to?(:status)).to be_truthy
    expect(application.respond_to?(:status=)).to be_truthy

    expect(group.respond_to?(:status)).to be_truthy
    expect(group.respond_to?(:status=)).to be_truthy

    expect(account.respond_to?(:status)).to be_truthy
    expect(account.respond_to?(:status=)).to be_truthy
  end

  it 'users status by default should be ENABLED' do
    expect(account.status).to eq('ENABLED')
  end

  it 'change user status' do
    account.status = 'DISABLED'
    account.save
    expect(reloaded_account.status).to eq('DISABLED')
  end

  it 'authenticate user with status ENABLED' do
    expect(authenticate_user.properties['account']['href']).to eq(account.href)
  end

  it "shouldn't authenticate users with status DISABLED, UNVERIFIED or LOCKED" do
    ['DISABLED', 'UNVERIFIED', 'LOCKED'].each do |status|
      account.status = status
      account.save
      expect { authenticate_user }.to raise_exception(Stormpath::Error)
    end
  end

  it 'assigning inappropriate status states should fail silently' do
    account.status = 'INVALID_STATUS_VALUE'
    expect { account.save }.to raise_error(Stormpath::Error)
  end
end
