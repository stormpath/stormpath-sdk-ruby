require 'spec_helper'

describe 'ProviderAccountResolver' do
  context 'given an instance of ProviderAccountResolver' do
    let(:data_store) { Stormpath::DataStore.new('', '', {}, '') }
    let(:provider_account_resolver) { Stormpath::Provider::AccountResolver.new(data_store) }
    let(:response) do
      provider_account_resolver.resolve_provider_account('foo/bar', account_request)
    end

    before do
      allow(test_api_client).to receive(:data_store).and_return(data_store)
      auth_result = Stormpath::Provider::AccountResult.new({}, test_api_client)
      allow(data_store).to receive(:create).and_return(auth_result)
      provider_account_resolver
    end

    context 'when integrating' do
      context 'without an account store' do
        let(:account_request) do
          Stormpath::Provider::AccountRequest.new(:facebook, :access_token, 'some-token')
        end

        it 'a ProviderResult is returned' do
          expect(response).to be_a Stormpath::Provider::AccountResult
        end
      end

      context 'with account store as a parameter' do
        let(:account_request) do
          Stormpath::Provider::AccountRequest.new(:facebook,
                                                  :access_token,
                                                  'some-token',
                                                  account_store: { name_key: 'app1' })
        end

        it 'a ProviderResult is returned' do
          expect(response).to be_a Stormpath::Provider::AccountResult
        end
      end
    end
  end
end
