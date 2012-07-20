require "stormpath-sdk"

include Stormpath::Client
include Stormpath::Http::Authc

describe "AUTH Tests" do

  before(:all) do
    @apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @signer = Sauthc1Signer.new
  end

  it "signature should sign correctly" do


    kSecret = @signer.to_utf8(Sauthc1Signer::AUTHENTICATION_SCHEME + @apiKey.secret)
    kDate = @signer.sign("key", kSecret, Sauthc1Signer::DEFAULT_ALGORITHM);
    kNonce = @signer.sign("nonce", kDate, Sauthc1Signer::DEFAULT_ALGORITHM);
    kSigning = @signer.sign(Sauthc1Signer::ID_TERMINATOR, kNonce, Sauthc1Signer::DEFAULT_ALGORITHM);

    value = "yeahwhateverTY/LO"
    rubyHexValue = @signer.to_hex value

    p kSecret
    p kDate
    p kNonce
    p kSigning

    p rubyHexValue

    javaHexValue = '79656168776861746576657254592f4c4f'

    rubyHexValue.should == javaHexValue


  end

end