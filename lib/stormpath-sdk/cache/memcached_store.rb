require 'memcached'

module Stormpath
  module Cache
    class MemcachedStore
      def initialize(opts = {})
        @memcached = Memcached.new(opts)
      end

      def get(key)
        entry = @memcached.get(key)
        entry && Stormpath::Cache::CacheEntry.from_h(MultiJson.load(entry))
      end

      def put(key, entry)
        @memcached.set(key, MultiJson.dump(entry.to_h))
      end

      def delete(key)
        @memcached.delete(key)
      end

      def clear
        @memcached.flush
      end

      def size
        @memcached.stats[:curr_items]
      end
    end
  end
end
