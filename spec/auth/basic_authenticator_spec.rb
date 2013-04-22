require "stormpath-sdk"

describe "BasicAuthenticator" do
  context "given an instance of BasicAuthenticator" do

    before do
      ds = Stormpath::DataStore.new "", ""
      auth_result = Stormpath::Authentication::AuthenticationResult.new ds
      ds.stub(:create).and_return(auth_result)
      @ba = Stormpath::Authentication::BasicAuthenticator.new ds
    end

    context "when authenticating" do
      before do
        @response = @ba.authenticate "foo/bar", Stormpath::Authentication::UsernamePasswordRequest.new("fake-username", "fake-password")
      end

      it "an AuthenticationResult is returned" do
        @response.should be_a Stormpath::Authentication::AuthenticationResult
      end
    end
  end
end
