require 'spec_helper'

describe "ProviderAccountResolver" do
  context "given an instance of ProviderAccountResolver" do

    before do
      data_store = Stormpath::DataStore.new "", {}, ""
      allow(test_api_client).to receive(:data_store).and_return(data_store)
      auth_result = Stormpath::Provider::AccountResult.new({}, test_api_client)
      allow(data_store).to receive(:create).and_return(auth_result)

      @provider_account_resolver = Stormpath::Provider::AccountResolver.new data_store
    end

    context "when integrating" do
      before do
        @response = @provider_account_resolver.resolve_provider_account "foo/bar", Stormpath::Provider::AccountRequest.new(:facebook, :access_token, "some-token")
      end

      it "an ProviderResult is returned" do
        expect(@response).to be_a Stormpath::Provider::AccountResult
      end
    end
  end
end
