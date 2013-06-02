module Stormpath
  module Cache
    class CacheManager

      def initialize(opts = nil)
        @caches = {}
      end

      def region_for(href)
        return nil unless href
        href.split('/')[-2]
      end

      def create_cache(region, opts)
        @caches[region] = Cache.new opts
      end

      def get_cache(region)
        @caches[region]
      end

      def stats
        Hash[ @caches.map { |region, cache| [region, cache.stats] } ]
      end
    end
  end
end
