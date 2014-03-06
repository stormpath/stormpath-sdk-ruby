#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class Stormpath::DataStore
  include Stormpath::Http
  include Stormpath::Util::Assert

  DEFAULT_SERVER_HOST = "api.stormpath.com"
  DEFAULT_API_VERSION = 1
  DEFAULT_BASE_URL = "https://" + DEFAULT_SERVER_HOST + "/v" + DEFAULT_API_VERSION.to_s

  CUSTOM_DATA_STORAGE_URL_REGEX = /#{DEFAULT_BASE_URL}\/(accounts|groups)\/\w+[\/]{0,1}$/
  CUSTOM_DATA_DELETE_FIELD_REGEX = /#{DEFAULT_BASE_URL}\/(accounts|groups)\/\w+\/customData\/\w+[\/]{0,1}$/
  NEW_ACCOUNT_STORE_MAPPING_URL = /#{DEFAULT_BASE_URL}\/accountStoreMappings$/
  EXISTING_ACCOUNT_STORE_MAPPING_URL = /#{DEFAULT_BASE_URL}\/accountStoreMappings\/\w+[\/]{0,1}$/

  HREF_PROP_NAME = Stormpath::Resource::Base::HREF_PROP_NAME
  CACHE_REGIONS = %w( applications directories accounts groups groupMemberships accountMemberships tenants customData )

  attr_reader :client, :request_executor, :cache_manager

  def initialize(request_executor, cache_opts, client, base_url = nil)
    assert_not_nil request_executor, "RequestExecutor cannot be null."

    @client = client
    @base_url = get_base_url(base_url)
    @request_executor = request_executor
    initialize_cache cache_opts
  end

  def initialize_cache(cache_opts)
    @cache_manager = Stormpath::Cache::CacheManager.new
    regions_opts = cache_opts[:regions] || {}
    CACHE_REGIONS.each do |region|
      region_opts = regions_opts[region.to_sym] || {}
      region_opts[:store] ||= cache_opts[:store]
      @cache_manager.create_cache region, region_opts
    end
  end

  def instantiate(clazz, properties = {})
    clazz.new properties, client
  end

  def get_resource(href, clazz, query=nil)
    q_href = qualify href

    data = execute_request('get', q_href, nil, query)
    instantiate clazz, data.to_hash
  end

  def create(parent_href, resource, return_type, options = {})
    #TODO assuming there is no ? in url
    parent_href = "#{parent_href}?#{URI.encode_www_form(options)}" unless options.empty?
    save_resource(parent_href, resource, return_type).tap do |returned_resource|
      if resource.kind_of? return_type
        resource.set_properties returned_resource.properties
      end
    end
  end

  def save(resource, clazz = nil)
    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"
    href = resource.href
    assert_not_nil href, "href or resource.href cannot be null."
    assert_true href.length > 0, "save may only be called on objects that have already been persisted (i.e. they have an existing href)."

    href = qualify(href)

    clazz ||= resource.class

    save_resource(href, resource, clazz).tap do |return_value|
      resource.set_properties return_value
    end
  end

  def delete(resource, property_name = nil)
    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"

    href = resource.href
    href += "/#{property_name}" if property_name
    href = qualify(href)
   
    execute_request('delete', href)
  end

  private

    def needs_to_be_fully_qualified(href)
      !href.downcase.start_with? 'http'
    end

    def qualify(href)
      needs_to_be_fully_qualified(href) ? @base_url + href : href
    end

    def execute_request(http_method, href, body=nil, query=nil)
      if http_method == 'get' && (cache = cache_for href)
        cached_result = cache.get href
        return cached_result if cached_result
      end

      request = Request.new(http_method, href, query, Hash.new, body)
      apply_default_request_headers request
      response = @request_executor.execute_request request
      result = response.body.length > 0 ? MultiJson.load(response.body) : ''

      if response.error?
        error = Stormpath::Resource::Error.new result
        raise Stormpath::Error.new error
      end

      if http_method == 'delete'
        clear_cache_on_delete(href)
        return nil
      end

      if result['href']
        cache_walk result
      else
        result
      end
    end

    def clear_cache_on_delete href
      if href =~ CUSTOM_DATA_DELETE_FIELD_REGEX
        href = href.split('/')[0..-2].join('/')
      end
      clear_cache href
    end

    def clear_cache_on_post href, resource
      if href =~ CUSTOM_DATA_STORAGE_URL_REGEX
        cached_href = href + "/customData"

      elsif href =~ NEW_ACCOUNT_STORE_MAPPING_URL
        if resource.properties["isDefaultAccountStore"] == true || resource.properties["isDefaultGroupStore"] == true
          cached_href = resource.application.href
        end

      elsif href =~ EXISTING_ACCOUNT_STORE_MAPPING_URL
        if resource.dirty_properties["isDefaultAccountStore"] != nil || resource.dirty_properties["isDefaultGroupStore"] != nil
          cached_href = resource.application.href
        end
      end

      clear_cache cached_href if cached_href
    end

    def clear_cache(href)
      cache = cache_for href
      cache.delete href if cache
    end

    def cache_walk(resource)
      assert_not_nil resource['href'], "resource must have 'href' property"
      items = resource['items']

      if items # collection resource
        resource['items'] = items.map do |item|
          cache_walk item
          { 'href' => item['href'] }
        end
      else     # single resource
        resource.each do |attr, value|
          if value.is_a? Hash and value['href']
            walked = cache_walk value
            resource[attr] = { 'href' => value['href'] } if value["href"]
            resource[attr]['items'] = walked['items'] if walked['items']
          end
        end
        cache resource if resource.length > 1
      end
      resource
    end

    def cache(resource)
      cache = cache_for resource['href']
      cache.put resource['href'], resource if cache
    end

    def cache_for(href)
      @cache_manager.get_cache(region_for href)
    end

    def region_for(href)
      return nil unless href
      if href.include? "/customData"
        region = href.split('/')[-1]
      else
        region = href.split('/')[-2]
      end
      CACHE_REGIONS.include?(region) ? region : nil
    end

    def apply_default_request_headers(request)
      request.http_headers.store 'Accept', 'application/json'
      request.http_headers.store 'User-Agent', 'Stormpath-RubySDK/' + Stormpath::VERSION

      if request.body and request.body.length > 0
        request.http_headers.store 'Content-Type', 'application/json'
      end
    end

    def save_resource(href, resource, return_type)
      assert_not_nil resource, "resource argument cannot be null."
      assert_not_nil return_type, "returnType class cannot be null."
      assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"

      q_href = qualify href

      clear_cache_on_post q_href, resource
      response = execute_request 'post', q_href, MultiJson.dump(to_hash(resource))

      instantiate return_type, response.to_hash
    end

    def get_base_url(base_url)
      base_url || DEFAULT_BASE_URL
    end

    def to_hash(resource)
      Hash.new.tap do |properties|
        resource.get_dirty_property_names.each do |name|
          ignore_camelcasing = resource_not_custom_data(resource, name) ? false : true
          property = resource.get_property name, ignore_camelcasing: ignore_camelcasing

          # Special use case is with Custom Data, it's hashes should not be simplified
          if property.kind_of?(Hash) and resource_not_custom_data resource, name
            property = to_simple_reference name, property
          end

          properties.store name, property
        end
      end
    end

    def to_simple_reference(property_name, hash)
      assert_true hash.has_key?(HREF_PROP_NAME), "Nested resource '#{property_name}' must have an 'href' property."

      href = hash[HREF_PROP_NAME]

      {HREF_PROP_NAME => href}
    end

    def resource_not_custom_data resource, name
      resource.class != Stormpath::Resource::CustomData and name != "customData"
    end

end
