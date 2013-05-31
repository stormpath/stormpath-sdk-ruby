module Stormpath
  module Cache
    class CacheManager
      REGIONS = %w( applications directories accounts groups groupMemberships tenants )

      def initialize(opts = nil)
        @caches = {}
        opts ||= {}
        regions = opts[:regions] || {}
        REGIONS.each do |r|
          cache_opts = regions[r] || regions[r.to_sym] || {}
          cache_opts[:store] = opts[:store]
          @caches[r] = Cache.new cache_opts
        end
      end

      def region_for(href)
        return nil unless href
        href.split('/')[-2]
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
