require 'spec_helper'

describe Stormpath::Cache::CacheStats do
  let(:cache_stats) do
    Stormpath::Cache::CacheStats.new
  end

  context 'by default' do
    it 'intializes counters' do
      expect(cache_stats.puts).to eq 0
      expect(cache_stats.hits).to eq 0
      expect(cache_stats.misses).to eq 0
      expect(cache_stats.expirations).to eq 0
      expect(cache_stats.size).to eq 0
    end
  end

  describe '#put' do
    before { cache_stats.put }

    it 'increments puts' do
      expect(cache_stats.puts).to eq 1
    end

    it 'increments size' do
      expect(cache_stats.puts).to eq 1
    end

    it 'updates summary' do
      expect(cache_stats.summary).to eq [1, 0, 0, 0, 1]
    end
  end

  describe '#hit' do
    before { cache_stats.hit }

    it 'increments hits' do
      expect(cache_stats.hits).to eq 1
    end

    it 'updates summary' do
      expect(cache_stats.summary).to eq [0, 1, 0, 0, 0]
    end
  end

  describe '#miss=' do
    context 'expired is true' do
      before { cache_stats.miss true }

      it 'increments misses' do
        expect(cache_stats.misses).to eq 1
      end

      it 'increments expirations' do
        expect(cache_stats.expirations).to eq 1
      end

      it 'updates summary' do
        expect(cache_stats.summary).to eq [0, 0, 1, 1, 0]
      end
    end

    context 'expired is true' do
      before { cache_stats.miss false }

      it 'increments misses' do
        expect(cache_stats.misses).to eq 1
      end

      it 'does not increment expirations' do
        expect(cache_stats.expirations).to eq 0
      end

      it 'updates summary' do
        expect(cache_stats.summary).to eq [0, 0, 1, 0, 0]
      end
    end
  end

  describe '#delete' do
    context 'when size is greater than zero' do
      before do
        3.times { cache_stats.put }
        cache_stats.delete
      end

      it 'decrements size' do
        expect(cache_stats.size).to eq 2
      end

      it 'updates summary' do
        expect(cache_stats.summary).to eq [3, 0, 0, 0, 2]
      end
    end

    context 'when size is zero' do
      before do
        cache_stats.delete
      end

      it 'does nothing' do
        expect(cache_stats.size).to eq 0
      end
    end
  end
end
