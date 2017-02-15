require 'spec_helper'

shared_examples 'request headers have the user agent' do
  it 'should be set' do
    expect(request.http_headers).to have_key('User-Agent')
    expect(request.http_headers['User-Agent']).to eq 'stormpath-sdk-ruby/1.7.0 ruby/2.3.1-p112 darwin/15'
  end
end

describe Stormpath::Http::HeaderInjection do
  let(:href) { 'http://api.stormpath.com/v1/applications/1234567' }
  let(:body) { MultiJson.dump(resource) }
  let(:request) do
    Stormpath::Http::Request.new('GET', href, nil, {}, body, test_api_key)
  end

  describe 'valid request' do
    let!(:apply_headers) { Stormpath::Http::HeaderInjection.for(request, body).perform }

    describe 'resource as hash data' do
      let(:resource) { application_attrs }

      it 'should apply default request headers with Content-Type' do
        expect(request.http_headers).to have_key('Accept')
        expect(request.http_headers['Accept']).to eq 'application/json'
        expect(request.http_headers).to have_key('Content-Type')
        expect(request.http_headers['Content-Type']).to eq 'application/json'
      end

      include_examples 'request headers have the user agent'
    end

    describe 'resource as form data' do
      let(:body) { OpenStruct.new(form_data?: true) }

      it 'should apply form data request headers' do
        expect(request.http_headers).to have_key('Content-Type')
        expect(request.http_headers['Content-Type']).to eq 'application/x-www-form-urlencoded'
      end

      include_examples 'request headers have the user agent'
    end

    describe 'resource is nil' do
      let(:body) { '' }

      it 'should apply default request headers without Content-Type' do
        expect(request.http_headers).to have_key('Accept')
        expect(request.http_headers['Accept']).to eq 'application/json'
        expect(request.http_headers).not_to have_key('Content-Type')
      end

      include_examples 'request headers have the user agent'
    end
  end

  describe 'invalid request' do
    let(:request) { nil }
    let(:resource) { application_attrs }
    let(:apply_headers) { Stormpath::Http::HeaderInjection.for(request, body).perform }

    it 'should raise a ArgumentError' do
      expect { apply_headers }.to raise_error(ArgumentError, 'Stormpath::Http::Request is required')
    end
  end
end
