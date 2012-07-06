require "stormpath-sdk"

include Stormpath::Client

describe Client do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
  end

  it "client should be created from api_key" do
    @client.should be_instance_of Client
  end

  it "tenant's properties must come complete'" do
    tenant = @client.current_tenant
    key = tenant.get_key
    name = tenant.get_name

    key.should be_kind_of String
    name.should be_kind_of String
  end
end



