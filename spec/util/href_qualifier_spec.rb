require 'spec_helper'

describe Stormpath::Util::HrefQualifier do
  let(:base_url) { 'https://api.stormpath.com/v1' }
  let(:qualified_href) { Stormpath::Util::HrefQualifier.new(base_url).qualify(href) }

  describe 'href is valid' do
    let(:href) { 'https://api.stormpath.com/v1/applications/123456789' }

    it 'should return the href' do
      expect(qualified_href).to eq href
    end
  end

  describe 'href misses the base url' do
    let(:href) { '/applications/123456789' }

    it 'should return the full href' do
      expect(qualified_href).to eq "#{base_url}#{href}"
    end
  end
end
