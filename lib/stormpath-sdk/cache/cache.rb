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
        @store = (opts[:store] || DEFAULT_STORE).new
        @stats = CacheStats.new
      end

      def get(k)
        entry = @store.get k
        if entry
          if entry.expired?
            @stats.miss true
            @store.delete k
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
        @store.put k, Entry.new(self, v)
        @stats.put
      end

      def delete(k)
        @store.delete k
      end

      def size
        @store.size
      end

      class Entry
        attr_reader :value

        def initialize(cache, value)
          @cache = cache
          @value = value
          @created_at = Time.now
          @last_accessed_at = @created_at
        end

        def touch
          @last_accessed_at = Time.now
        end

        def expired?
          now = Time.now
          now > (@created_at + @cache.ttl_seconds) || now > (@last_accessed_at + @cache.tti_seconds)
        end
      end
    end

  end
end
