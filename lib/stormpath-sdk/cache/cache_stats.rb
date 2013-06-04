module Stormpath
  module Cache
    class CacheStats
      attr_accessor :puts, :hits, :misses, :expirations, :size

      def initialize
        @puts = @hits = @misses = @expirations = @size = 0
      end

      def put
        @puts += 1
        @size += 1
      end

      def hit
        @hits += 1
      end

      def miss(expired = false)
        @misses += 1
        @expirations += 1 if expired
      end

      def delete
        if @size > 0
          @size -= 1
        end
      end

      def summary
        [@puts, @hits, @misses, @expirations]
      end
    end
  end
end
