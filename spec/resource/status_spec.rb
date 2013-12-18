require 'spec_helper'

describe Stormpath::Resource::Status, :vcr do
  
  def authenticate_user
    auth_request = Stormpath::Authentication::UsernamePasswordRequest.new "Rubyy", 'P@$$w0rd'
    application.authenticate_account auth_request
  end

  let(:directory) { test_api_client.directories.create name: 'testDirectory', description: 'testDirectory' }

  let(:application) { test_api_client.applications.create name: 'testApplication', description: 'testApplication' }
  
  let(:group) { directory.groups.create name: 'testGroup', description: 'testGroup' }

  let!(:account) do
    directory.accounts.create email: 'test@example.com', password: 'P@$$w0rd', given_name: "Ruby SDK", surname: 'SDK', username: "Rubyy"
  end

  let(:status_hash) {{"ENABLED" => "ENABLED", "DISABLED" => "DISABLED"}}

  let(:account_status_hash) { status_hash.merge "UNVERIFIED" => "UNVERIFIED", "LOCKED" => "LOCKED"}

  let(:reloaded_account) { test_api_client.accounts.get account.href }

  after do
    application.delete if application
    directory.delete if directory # group and account will be automatically deleted when this is triggered
  end
    
  # it "should respond to status getter and setter" do
  #   expect(directory.respond_to? :status).to eq(true)
  #   expect(directory.respond_to? :status=).to eq(true)

  #   expect(application.respond_to? :status).to eq(true)
  #   expect(application.respond_to? :status=).to eq(true)
    
  #   expect(group.respond_to? :status).to eq(true)
  #   expect(group.respond_to? :status=).to eq(true)

  #   expect(account.respond_to? :status).to eq(true)
  #   expect(account.respond_to? :status=).to eq(true)
  # end

  # it "compare status hashes" do
  #   expect(directory.status_hash).to eq(status_hash)
  #   expect(application.status_hash).to eq(status_hash)
    
  #   expect(group.status_hash).to eq(status_hash)
  #   expect(account.status_hash).to eq(account_status_hash)
  # end

  # it "users status by default should be ENABLED" do
  #   expect(account.status).to eq("ENABLED")
  # end

  # it "change user status" do
  #   account.status = "DISABLED"
  #   account.save
  #   expect(reloaded_account.status).to eq("DISABLED")
  # end
 
  it "authenticate user with status ENABLED" do
      account.status = "ENABLED"
      account.save
      expect(reloaded_account.status).to eq("ENABLED")
      expect(authenticate_user).to_not raise_error(Exception)
  end

end
