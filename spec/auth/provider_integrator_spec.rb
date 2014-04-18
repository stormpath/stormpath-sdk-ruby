require 'spec_helper'

describe "ProviderIntegrator" do
  context "given an instance of ProviderIntegrator" do

    before do
      data_store = Stormpath::DataStore.new "", {}, ""
      allow(test_api_client).to receive(:data_store).and_return(data_store)
      auth_result = Stormpath::Authentication::ProviderAccountResult.new({}, test_api_client)
      allow(data_store).to receive(:create).and_return(auth_result)

      @provider_integrator = Stormpath::Authentication::ProviderIntegrator.new data_store
    end

    context "when integrating" do
      before do
        @response = @provider_integrator.get_account "foo/bar", Stormpath::Authentication::FacebookAccountRequest.new(:access_token, "some-token")
      end

      it "an ProviderResult is returned" do
        expect(@response).to be_a Stormpath::Authentication::ProviderAccountResult
      end
    end
  end
end
