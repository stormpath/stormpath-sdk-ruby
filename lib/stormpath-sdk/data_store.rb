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

  attr_reader :client

  def initialize(request_executor, cache_manager, client, *base_url)
    assert_not_nil request_executor, "RequestExecutor cannot be null."

    @client = client
    @base_url = get_base_url(*base_url)
    @request_executor = request_executor
    @cache_manager = cache_manager
  end

  def instantiate(clazz, properties = {})
    clazz.new properties, client
  end

  def get_resource(href, clazz)
    q_href = if needs_to_be_fully_qualified href
               qualify href
             else
               href
             end

    data = execute_request('get', q_href, nil)
    instantiate clazz, data.to_hash
  end

  def create(parent_href, resource, return_type)
    save_resource(parent_href, resource, return_type).tap do |returned_resource|
      if resource.kind_of? return_type
        resource.set_properties to_hash(returned_resource)
      end
    end
  end

  def save(resource, clazz = nil)
    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"

    href = resource.href
    assert_true href.length > 0, "save may only be called on objects that have already been persisted (i.e. they have an existing href)."

    href = if needs_to_be_fully_qualified(href)
             qualify(href)
           else
             href
           end

    clazz ||= resource.class

    save_resource(href, resource, clazz).tap do |return_value|
      resource.set_properties return_value
    end
  end

  def delete(resource)
    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"

    execute_request('delete', resource.href, nil)
  end

  def cache_stats
    @cache_manager.stats
  end

  protected

  def needs_to_be_fully_qualified(href)
    !href.downcase.start_with? 'http'
  end

  def qualify(href)
    slash_added = ''

    if !href.start_with? '/'
      slash_added = '/'
    end

    @base_url + slash_added + href
  end

  private

  def execute_request(http_method, href, body)
    if http_method == 'get' && (cache = cache_for href)
      cached_result = cache.get href
      return cached_result if cached_result
    end

    request = Request.new(http_method, href, nil, Hash.new, body)
    apply_default_request_headers request
    response = @request_executor.execute_request request

    result = response.body.length > 0 ? MultiJson.load(response.body) : ''

    if response.error?
      error = Stormpath::Resource::Error.new result
      raise Stormpath::Error.new error
    end

    if http_method == 'delete'
      cache = cache_for href
      cache.delete href if cache
    else
      result_href = result['href']
      cache = cache_for result_href
      cache.put result_href, result if cache
    end

    result
  end

  def cache_for(href)
    region = @cache_manager.region_for href
    @cache_manager.get_cache region
  end

  def apply_default_request_headers(request)
    request.http_headers.store 'Accept', 'application/json'
    request.http_headers.store 'User-Agent', 'Stormpath-RubySDK/' + Stormpath::VERSION

    if !request.body.nil? and request.body.length > 0
      request.http_headers.store 'Content-Type', 'application/json'
    end
  end

  def save_resource(href, resource, return_type)
    assert_not_nil resource, "resource argument cannot be null."
    assert_not_nil return_type, "returnType class cannot be null."
    assert_kind_of Stormpath::Resource::Base, resource, "resource argument must be instance of Stormpath::Resource::Base"

    q_href = if needs_to_be_fully_qualified href
               qualify href
             else
               href
             end

    response = execute_request('post', q_href, MultiJson.dump(to_hash(resource)))
    instantiate return_type, response.to_hash
  end

  def get_base_url(*base_url)
    (!base_url.empty? and !base_url[0].nil?) ?
      base_url[0] :
      "https://" + DEFAULT_SERVER_HOST + "/v" + DEFAULT_API_VERSION.to_s
  end

  def to_hash(resource)
    Hash.new.tap do |properties|
      resource.get_property_names.each do |name|
        property = resource.get_property name

        if property.kind_of? Hash
          property = to_simple_reference name, property
        end

        properties.store name, property
      end
    end
  end

  def to_simple_reference(property_name, hash)
    href_prop_name = Stormpath::Resource::Base::HREF_PROP_NAME
    assert_true(
      (hash.kind_of?(Hash) and !hash.empty? and hash.has_key?(href_prop_name)),
      "Nested resource '#{property_name}' must have an 'href' property."
    )

    href = hash[href_prop_name]

    {href_prop_name => href}
  end
end
