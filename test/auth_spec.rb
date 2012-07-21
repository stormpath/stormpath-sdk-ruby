require "stormpath-sdk"

include Stormpath::Client
include Stormpath::Http::Authc
include Stormpath::Http

describe "AUTH Tests" do

  before(:all) do
    @apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @signer = Sauthc1Signer.new
  end

  it "signature should sign correctly" do


    href = "http://localhost:8080/v1/tenant"

    request = Request.new('get', href, nil, Hash.new, nil)

    signer = Sauthc1Signer.new
    signer.sign_request request, @apiKey

    p 'Done with signing'


  end

end