module Stormpath
  class DataStore
    include Stormpath::Http
    include Stormpath::Util::Assert

    DEFAULT_SERVER_HOST = 'api.stormpath.com'.freeze
    DEFAULT_API_VERSION = 1
    DEFAULT_BASE_URL = 'https://' + DEFAULT_SERVER_HOST + '/v' + DEFAULT_API_VERSION.to_s

    attr_reader :client, :request_executor, :cache_manager, :api_key, :base_url, :qualifier

    def initialize(request_executor, api_key, cache_opts, client, base_url = nil)
      assert_not_nil request_executor, 'RequestExecutor cannot be null.'

      @request_executor = request_executor
      @api_key = api_key
      @client = client
      @base_url = base_url || DEFAULT_BASE_URL
      @cache_manager = Stormpath::Cache::CacheManager.new(@base_url, cache_opts)
      @qualifier = Stormpath::Util::HrefQualifier.new(@base_url)
    end

    def instantiate(clazz, properties = {})
      clazz.new(properties, client)
    end

    def get_resource(href, clazz, query = nil)
      data = execute_request('get', qualify(href), nil, query)

      clazz = clazz.call(data) if clazz.respond_to? :call

      instantiate(clazz, data.to_hash)
    end

    def create(parent_href, resource, return_type, options = {})
      parent_href = "#{parent_href}?#{URI.encode_www_form(options)}" if options.present?

      save_resource(parent_href, resource, return_type).tap do |returned_resource|
        if resource.is_a?(return_type)
          resource.set_properties(returned_resource.properties)
        end
      end
    end

    def save(resource, clazz = nil)
      assert_not_nil(resource, 'resource argument cannot be null.')
      assert_kind_of(Stormpath::Resource::Base, resource, 'resource argument must be instance of Base')
      href = resource.href
      assert_not_nil(href, 'href or resource.href cannot be null.')
      assert_true(href.present?, 'save may only be called on objects that have already been persisted (i.e. they have an existing href).')

      clazz ||= resource.class

      save_resource(qualify(href), resource, clazz).tap do |return_value|
        resource.set_properties(return_value)
      end
    end

    def delete(resource, property_name = nil)
      assert_not_nil(resource, 'resource argument cannot be null.')
      assert_kind_of(Stormpath::Resource::Base, resource, 'resource argument must be instance of Base')

      href = resource.href
      href += "/#{property_name}" if property_name
      href = qualify(href)

      execute_request('delete', href)
      cache_manager.clear_cache_on_delete(href)
    end

    def execute_raw_request(href, body, klass)
      request = Request.new('POST', href, nil, {}, body.to_json, api_key)
      apply_headers_to_request(request)
      response = request_executor.execute_request(request)
      result = response.body.present? ? MultiJson.load(response.body) : ''

      raise_error_for(result) if response.error?

      cache_manager.cache_walk(result)
      instantiate(klass, result)
    end

    private

    def save_resource(href, resource, return_type)
      assert_not_nil(resource, 'resource argument cannot be null.')
      assert_not_nil(return_type, 'returnType class cannot be null.')
      assert_kind_of(Stormpath::Resource::Base, resource, 'resource argument must be instance of Base')

      cache_manager.clear_cache_on_save(resource)
      response = execute_request('post', qualify(href), resource)
      instantiate(return_type, parse_response(response))
    end

    def execute_request(http_method, href, resource = nil, query = nil)
      if http_method == 'get' && (cache = cache_manager.cache_for(href))
        cached_result = cache.get(href)
        return cached_result if cached_result
      end

      body = Stormpath::Util::BodyExtractor.for(resource).call

      request = Request.new(http_method, href, query, {}, body, api_key)
      apply_headers_to_request(request, resource)

      response = request_executor.execute_request(request)

      result = response.body.present? ? MultiJson.load(response.body) : ''

      raise_error_for(result) if response.error?

      if resource.is_a?(Stormpath::Provider::AccountAccess)
        is_new_account = response.http_status == 201
        result = { is_new_account: is_new_account, account: result }
      end

      return if http_method == 'delete'

      if result[Stormpath::Resource::Base::HREF_PROP_NAME] && !resource.try(:mapping_rules?)
        cache_manager.cache_walk(result)
      else
        result
      end
    end

    def parse_response(response)
      return {} if response.is_a?(String) && response.blank?
      response.to_hash
    end

    def qualify(href)
      qualifier.qualify(href)
    end

    def apply_headers_to_request(request, resource = nil)
      Stormpath::Http::HeaderInjection.for(request, resource).perform
    end

    def raise_error_for(result)
      raise Stormpath::Error, Stormpath::Resource::Error.new(result)
    end
  end
end
