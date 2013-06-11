require 'spec_helper'
require 'timecop'

describe Stormpath::Cache::Cache do
  let(:cache) { Stormpath::Cache::Cache.new ttl_seconds: 7, tti_seconds: 3 }
  let(:now)   { Time.now }

  before do
    cache.put 'foo', 'bar'
  end

  after do
    Timecop.return
  end

  describe '#put' do
    it 'adds entry to the cache' do
      expect(cache.size).to eq(1)
      expect(cache.stats.summary).to eq [1, 0, 0, 0, 1]
    end
  end

  describe '#get' do
    context 'miss' do
      before do
        @foo = cache.get 'not-foo'
      end

      it 'gets nil' do
        expect(@foo).not_to be
        expect(cache.stats.summary).to eq [1, 0, 1, 0, 1]
      end
    end

    context 'live before tti' do
      before do
        Timecop.freeze now + 2
        @foo = cache.get 'foo'
      end

      it 'gets bar' do
        expect(@foo).to eq('bar')
        expect(cache.stats.summary).to eq [1, 1, 0, 0, 1]
      end
    end

    context 'live after tti' do
      before do
        Timecop.freeze now + 2
        cache.get 'foo'
        Timecop.freeze now + 5
        @foo = cache.get 'foo'
      end

      it 'gets bar' do
        expect(@foo).to eq('bar')
        expect(cache.stats.summary).to eq [1, 2, 0, 0, 1]
      end
    end

    context 'expired by tti' do
      before do
        Timecop.freeze now + 4
        @foo = cache.get 'foo'
      end

      it 'gets nil' do
        expect(@foo).not_to be
        expect(cache.stats.summary).to eq [1, 0, 1, 1, 1]
      end
    end

    context 'expired by ttl' do
      before do
        Timecop.freeze now + 2
        cache.get 'foo'
        Timecop.freeze now + 5
        cache.get 'foo'
        Timecop.freeze now + 8
        @foo = cache.get 'foo'
      end

      it 'gets nil' do
        expect(@foo).not_to be
        expect(cache.stats.summary).to eq [1, 2, 1, 1, 1]
      end
    end
  end
end
