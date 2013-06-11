require 'spec_helper'
require 'timecop'

describe Stormpath::Http::Authc::Sauthc1Signer do
  let(:fake_uuid_generator) do
    Proc.new { 'fake-uuid' }
  end
  let(:signer) do
    Stormpath::Http::Authc::Sauthc1Signer.new fake_uuid_generator
  end

  after do
    Timecop.return
  end

  describe '#sign_request' do
    context 'for two GET requests to the same URL' do
      context 'with one request using the query_string hash' do
        let(:fake_api_key) { Stormpath::ApiKey.new('foo', 'bar') }

        let(:empty_query_hash_request) do
          Stormpath::Http::Request.new 'get', 'http://example.com/resources/abc123?q=red blue', nil, Hash.new, nil
        end

        let(:filled_query_hash_request) do
          Stormpath::Http::Request.new 'get', 'http://example.com/resources/abc123', {'q' => 'red blue'}, Hash.new, nil
        end

        before do
          Timecop.freeze(Time.now)
          signer.sign_request empty_query_hash_request, fake_api_key
          signer.sign_request filled_query_hash_request, fake_api_key
        end

        it 'assigns identical headers to both requests' do
          expect(empty_query_hash_request.http_headers['Host']).to eq(filled_query_hash_request.http_headers['Host'])
          expect(empty_query_hash_request.http_headers['Authorization']).to eq(filled_query_hash_request.http_headers['Authorization'])
        end
      end
    end
  end
end
