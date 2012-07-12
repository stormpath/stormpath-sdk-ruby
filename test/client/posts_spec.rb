require "stormpath-sdk"

include Stormpath::Authentication

describe "POST Operations" do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
    @dataStore = @client.dataStore
  end

  it "application should be able to authenticate" do

    href = 'applications/A0atUpZARYGApaN5f88O3A'
    application = @dataStore.get_resource href, Application

    result = application.authenticate UsernamePasswordRequest.new 'kentucky', 'super_P4ss', nil

    result.should be_kind_of Account
  end

end