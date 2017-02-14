module Stormpath
  module Cache
    class CacheManager
      CACHE_REGIONS = %w(applications directories accounts groups groupMemberships
                         accountMemberships tenants customData provider providerData).freeze

      def initialize(opts = nil)
        @caches = {}
        custom_region_opts = opts[:regions] || {}
        CACHE_REGIONS.each do |region|
          region_opts = custom_region_opts[region.to_sym] || {}
          region_opts[:store] ||= opts[:store]
          region_opts[:store_opts] ||= opts[:store_opts]
          create_cache(region, region_opts)
        end
      end

      def create_cache(region, opts)
        @caches[region] = Cache.new(opts)
      end

      def get_cache(region)
        @caches[region]
      end

      def stats
        Hash[@caches.map { |region, cache| [region, cache.stats] }]
      end
    end
  end
end
