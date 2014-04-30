require 'spec_helper'

describe "ProviderIntegrator" do
  context "given an instance of ProviderIntegrator" do

    before do
      data_store = Stormpath::DataStore.new "", {}, ""
      allow(test_api_client).to receive(:data_store).and_return(data_store)
      auth_result = Stormpath::Provider::ProviderAccountResult.new({}, test_api_client)
      allow(data_store).to receive(:create).and_return(auth_result)

      @provider_account_resolver = Stormpath::Provider::ProviderAccountResolver.new data_store
    end

    context "when integrating" do
      before do
        @response = @provider_account_resolver.resolve_provider_account "foo/bar", Stormpath::Provider::FacebookAccountRequest.new(:access_token, "some-token")
      end

      it "an ProviderResult is returned" do
        expect(@response).to be_a Stormpath::Provider::ProviderAccountResult
      end
    end
  end
end
