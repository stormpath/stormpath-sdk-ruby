require 'spec_helper'

describe "BasicAuthenticator" do
  context "given an instance of BasicAuthenticator" do

    before do
      data_store = Stormpath::DataStore.new "", {}, ""
      allow(test_api_client).to receive(:data_store).and_return(data_store)
      auth_result = Stormpath::Authentication::AuthenticationResult.new({}, test_api_client)
      allow(data_store).to receive(:create).and_return(auth_result)

      @basic_authenticator = Stormpath::Authentication::BasicAuthenticator.new data_store
    end

    context "when authenticating" do
      before do
        @response = @basic_authenticator.authenticate "foo/bar", Stormpath::Authentication::UsernamePasswordRequest.new("fake-username", "fake-password")
      end

      it "an AuthenticationResult is returned" do
        expect(@response).to be_a Stormpath::Authentication::AuthenticationResult
      end
    end
  end
end
