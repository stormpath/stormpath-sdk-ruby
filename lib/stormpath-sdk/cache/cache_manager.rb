module Stormpath
  module Cache
    class CacheManager
      include Stormpath::Util::Assert

      CACHE_REGIONS = %i(applications directories accounts groups groupMemberships
                         accountMemberships tenants customData provider providerData).freeze
      HREF_PROP_NAME = Stormpath::Resource::Base::HREF_PROP_NAME

      def initialize(base_url, opts = nil)
        @base_url = base_url
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
        @caches[region.try(:to_sym)]
      end

      def stats
        Hash[@caches.map { |region, cache| [region, cache.stats] }]
      end

      def cache_walk(resource)
        assert_not_nil(resource[HREF_PROP_NAME], "resource must have 'href' property")
        items = resource['items']

        if items # collection resource
          resource['items'] = items.map do |item|
            cache_walk(item)
            { HREF_PROP_NAME => item[HREF_PROP_NAME] }
          end
        else     # single resource
          resource.each do |attr, value|
            next unless value.is_a?(Hash) && value[HREF_PROP_NAME]
            walked = cache_walk(value)
            resource[attr] = { HREF_PROP_NAME => value[HREF_PROP_NAME] }
            resource[attr]['items'] = walked['items'] if walked['items']
          end
          cache_it(resource) if resource.length > 1
        end

        resource
      end

      def cache_for(href)
        raise ArgumentError, "href property can't be blank" if href.blank?
        get_cache(region_for(href))
      end

      def clear_cache_on_delete(href)
        href = omit_custom_data_id_from(href) if href =~ custom_data_url_regex
        clear_cache(href)
        nil
      end

      def clear_cache_on_save(resource)
        if resource.is_a?(Stormpath::Resource::CustomDataStorage)
          clear_custom_data_cache_on_custom_data_storage_save(resource)
        elsif resource.is_a?(Stormpath::Resource::AccountStoreMapping)
          clear_application_cache_on_account_store_save(resource)
        end
      end

      private

      def cache_it(resource)
        cache = cache_for(resource[HREF_PROP_NAME])
        cache.put(resource[HREF_PROP_NAME], resource) if cache
      end

      def clear_cache(href)
        cache = cache_for(href)
        cache.delete(href) if cache
      end

      def region_for(href)
        return nil if href.nil?
        region = if href.include?('/customData')
                   href.split('/')[-1]
                 else
                   href.split('/')[-2]
                 end
        CACHE_REGIONS.include?(region.to_sym) ? region.to_sym : nil
      end

      def clear_custom_data_cache_on_custom_data_storage_save(resource)
        if resource.dirty_properties.key?('customData') && (resource.new? == false)
          clear_cache("#{resource.href}/customData")
        end
      end

      def clear_application_cache_on_account_store_save(resource)
        if resource.new?
          if resource.default_account_store? == true || resource.default_group_store? == true
            clear_cache(resource.application.href)
          end
        else
          if resource.dirty_properties['isDefaultAccountStore'].present? || resource.dirty_properties['isDefaultGroupStore'].present?
            clear_cache(resource.application.href)
          end
        end
      end

      def custom_data_url_regex
        /#{@base_url}\/(accounts|groups)\/\w+\/customData\/\w+[\/]{0,1}$/
      end

      def omit_custom_data_id_from(href)
        href.split('/')[0..-2].join('/')
      end
    end
  end
end
