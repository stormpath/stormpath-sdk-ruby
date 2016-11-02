require 'memcached'

module Stormpath
  module Cache
    class MemcachedStore
      attr_reader :memcached, :options

      def initialize(opts = {})
        @options = opts.blank? ? { host: 'localhost:11211' } : opts
        @memcached = Memcached.new(options[:host], options_without_host)
      end

      def get(key)
        begin
          entry = memcached.get(key)
          entry && Stormpath::Cache::CacheEntry.from_h(MultiJson.load(entry))
        rescue Memcached::NotFound
          nil
        end
      end

      def put(key, entry)
        memcached.set(key, MultiJson.dump(entry.to_h))
      end

      def delete(key)
        memcached.delete(key)
      end

      def clear
        memcached.flush
      end

      def size
        memcached.stats[:curr_items]
      end

      def options_without_host
        options.tap { |hs| hs.delete(:host) }
      end
    end
  end
end
