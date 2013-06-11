require 'spec_helper'

describe Stormpath::ApiKey do
  describe '.new' do
    context 'given an id and secret' do
      id = 'an_api_id'
      secret = 'a_secret'
      let(:apiKey) { Stormpath::ApiKey.new(id, secret) }

      it 'sets the id' do
        expect(apiKey.id).to eq(id)
      end

      it 'sets the secret' do
        expect(apiKey.secret).to eq(secret)
      end
    end
  end
end
