module Stormpath
  module Cache
    class CacheManager
      REGIONS = %w( applications directories accounts groups groupMemberships tenants )

      def initialize(opts = {})
        @caches = {}
        REGIONS.each { |r| @caches[r] = MemoryStore.new }
      end

      def region_for(href)
        return nil unless href
        href.split('/')[-2]
      end

      def get_cache(region)
        @caches[region]
      end
    end
  end
end
