module Stormpath
  module Cache
    class CacheStats
      attr_accessor :puts, :hits, :misses, :expirations

      def initialize
        @puts = @hits = @misses = @expirations = 0
      end

      def put
        @puts += 1
      end

      def hit
        @hits += 1
      end

      def miss(expired = false)
        @misses += 1
        @expirations += 1 if expired
      end

      def summary
        [@puts, @hits, @misses, @expirations]
      end
    end
  end
end
