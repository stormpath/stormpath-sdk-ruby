require 'spec_helper'

describe Stormpath::Util::UriBuilder do
  context 'url contains forward slash' do
    let(:url) { 'https://kfsdlk34223lke:3o5pfd9jlc/s29kf@api.stormpath.com/accounts' }
    let(:builder) { Stormpath::Util::UriBuilder.new(url) }

    it 'should contain escaped url' do
      expect(builder.escaped_url).to eq 'https://kfsdlk34223lke:3o5pfd9jlc%2Fs29kf@api.stormpath.com/accounts'
    end

    it 'should contain userinfo' do
      expect(builder.userinfo).to eq 'kfsdlk34223lke:3o5pfd9jlc/s29kf'
    end

    it 'should contain uri' do
      expect(builder.uri).to eq URI('https://kfsdlk34223lke:3o5pfd9jlc%2Fs29kf@api.stormpath.com/accounts')
    end
  end

  context "url doesn't contain forward slash" do
    let(:url) { 'https://kfsdlk34223lke:3o5pfd9jlcs29kf@api.stormpath.com/accounts' }
    let(:builder) { Stormpath::Util::UriBuilder.new(url) }

    it 'should contain escaped url' do
      expect(builder.escaped_url).to eq 'https://kfsdlk34223lke:3o5pfd9jlcs29kf@api.stormpath.com/accounts'
    end

    it 'should contain userinfo' do
      expect(builder.userinfo).to eq 'kfsdlk34223lke:3o5pfd9jlcs29kf'
    end

    it 'should contain uri' do
      expect(builder.uri).to eq URI('https://kfsdlk34223lke:3o5pfd9jlcs29kf@api.stormpath.com/accounts')
    end
  end

  context 'url is invalid' do
    let(:url) { 'invalid url' }

    it 'should raise error' do
      expect do
        Stormpath::Util::UriBuilder.new(url).uri
      end.to raise_error
    end
  end
end
