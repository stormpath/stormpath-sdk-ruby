module Stormpath
  module Cache
    DEFAULT_STORE = MemoryStore
    DEFAULT_TTL_SECONDS = 5 * 60
    DEFAULT_TTI_SECONDS = 5 * 60

    class Cache
      attr_reader :stats, :ttl_seconds, :tti_seconds

      def initialize(opts = {})
        @ttl_seconds = opts[:ttl_seconds] || DEFAULT_TTL_SECONDS
        @tti_seconds = opts[:tti_seconds] || DEFAULT_TTI_SECONDS
        store_opts = opts[:store_opts] || {}
        @store = (opts[:store] || DEFAULT_STORE).new(store_opts)
        @stats = CacheStats.new
      end

      def get(k)
        if entry = @store.get(k)
          if entry.expired? @ttl_seconds, @tti_seconds
            @stats.miss true
            @store.delete(k)
            nil
          else
            @stats.hit
            entry.touch
            entry.value
          end
        else
          @stats.miss
          nil
        end
      end

      def put(k, v)
        @store.put k, CacheEntry.new(v)
        @stats.put
      end

      def delete(k)
        @store.delete(k)
        @stats.delete
      end

      def clear
        @store.clear
      end

      def size
        @stats.size
      end
    end
  end
end
