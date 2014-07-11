require 'spec_helper'

describe Stormpath::Resource::Status, :vcr do

  def authenticate_user
    auth_request = Stormpath::Authentication::UsernamePasswordRequest.new 'test@example.com', 'P@$$w0rd'
    account_store_mapping unless account_store_mapping
    application.authenticate_account auth_request
  end

  let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'testDirectory for statuses' }

  let(:application) { test_api_client.applications.create name: random_application_name, description: 'testDirectory for statuses' }

  let(:group) { directory.groups.create name: 'testGroup', description: 'testGroup' }

  let(:account_store_mapping) { test_api_client.account_store_mappings.create application: application, account_store: directory }

  let!(:account) { directory.accounts.create email: 'test@example.com', password: 'P@$$w0rd', given_name: "Ruby SDK", surname: 'SDK' }

  let(:status_hash) {{ "ENABLED" => "ENABLED", "DISABLED" => "DISABLED" }}

  let(:account_status_hash) { status_hash.merge "UNVERIFIED" => "UNVERIFIED", "LOCKED" => "LOCKED"}

  let(:reloaded_account) { test_api_client.accounts.get account.href }

  after do
    application.delete if application
    directory.delete if directory
  end

  it "should respond to status getter and setter" do
    expect(directory.respond_to? :status).to be_true
    expect(directory.respond_to? :status=).to be_true

    expect(application.respond_to? :status).to be_true
    expect(application.respond_to? :status=).to be_true

    expect(group.respond_to? :status).to be_true
    expect(group.respond_to? :status=).to be_true

    expect(account.respond_to? :status).to be_true
    expect(account.respond_to? :status=).to be_true
  end

  it "compare status hashes" do
    expect(directory.status_hash).to eq(status_hash)
    expect(application.status_hash).to eq(status_hash)

    expect(group.status_hash).to eq(status_hash)
    expect(account.status_hash).to eq(account_status_hash)
  end

  it "users status by default should be ENABLED" do
    expect(account.status).to eq("ENABLED")
  end

  it "change user status" do
    account.status = "DISABLED"
    account.save
    expect(reloaded_account.status).to eq("DISABLED")
  end

  it "authenticate user with status ENABLED" do
    expect(authenticate_user.properties["account"]["href"]).to eq(account.href)
  end

  it "shouldn't authenticate users with status DISABLED, UNVERIFIED or LOCKED" do
    ["DISABLED", "UNVERIFIED", "LOCKED"].each do |status|
      account.status = status
      account.save
      expect{authenticate_user}.to raise_exception(Stormpath::Error)
    end
  end

  it 'assigning inappropriate status states should fail silently' do
    account.status = "INVALID_STATUS_VALUE"
    expect(account.status).to eq("ENABLED")
  end

end
