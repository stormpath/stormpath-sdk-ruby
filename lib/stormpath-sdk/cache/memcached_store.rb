require 'memcached'

module Stormpath
  module Cache
    class MemcachedStore
      def initialize(opts = {})
        options = nil if opts.blank?
        @memcached = Memcached.new(options)
      end

      def get(key)
        begin
          entry = @memcached.get(key)
          entry && Stormpath::Cache::CacheEntry.from_h(MultiJson.load(entry))
        rescue Memcached::NotFound
          nil
        end
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
