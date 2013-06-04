require 'spec_helper'
require 'timecop'

describe Stormpath::Cache::CacheEntry do
  after do
    Timecop.return
  end

  context 'by default' do
    let(:cache_entry) do
      Stormpath::Cache::CacheEntry.new 'foo'
    end

    let(:now) { Time.now }
    before { Timecop.freeze now }

    it 'initializes the value' do
      expect(cache_entry.value).to eq 'foo'
    end

    it 'initializes the creation time to now' do
      expect(cache_entry.created_at).to eq now
    end

    it 'initializes the last accessed time to now' do
      expect(cache_entry.last_accessed_at).to eq now
    end
  end

  describe '#touch' do
    let(:cache_entry) do
      Stormpath::Cache::CacheEntry.new 'foo'
    end

    let(:now) { Time.now }

    before do
      Timecop.freeze now
      cache_entry.touch
    end

    it 'updates the last accessed at time' do
      expect(cache_entry.last_accessed_at).to eq now
    end
  end

  describe '#expired?=' do
    let(:now) { Time.now }

    let(:ttl_seconds) { 300 }
    let(:tti_seconds) { 300 }

    context 'has not expired' do
      let(:cache_entry) do
        Stormpath::Cache::CacheEntry.new 'foo'
      end

      let(:expired) do
        cache_entry.expired? ttl_seconds, tti_seconds
      end

      it 'returns false' do
        expect(expired).to be_false
      end
    end

    context 'when TTL has expired' do
      before do
        cache_entry = Stormpath::Cache::CacheEntry.new 'foo'
        Timecop.freeze now + ttl_seconds + 1

        @expired = cache_entry.expired? ttl_seconds, tti_seconds
      end

      it 'returns true' do
        expect(@expired).to be_true
      end
    end

    context 'when TTI has expired' do
      before do
        cache_entry = Stormpath::Cache::CacheEntry.new 'foo'
        Timecop.freeze now + tti_seconds + 1

        @expired = cache_entry.expired? ttl_seconds, tti_seconds
      end

      it 'returns true' do
        expect(@expired).to be_true
      end
    end
  end
end