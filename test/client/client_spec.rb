require "stormpath-sdk"

describe Client do

  before(:all) do
    apiKey = ApiKey.new "", ""
    @client = Client.new apiKey, ""
  end

  it "client should be created from api_key" do
    @client.should be_instance_of Client
  end

  it "client should return a tenant" do
    @client.current_tenant.should be_instance_of Tenant
  end
end



