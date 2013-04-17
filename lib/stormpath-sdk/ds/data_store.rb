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
  include Stormpath::ResourceUtils
  include Stormpath::Util::Assert

  DEFAULT_SERVER_HOST = "api.stormpath.com"

  DEFAULT_API_VERSION = 1

  def initialize(request_executor, *base_url)

    assert_not_nil request_executor, "RequestExecutor cannot be null."
    @base_url = get_base_url *base_url
    @request_executor = request_executor
    @resource_factory = Stormpath::ResourceFactory.new(self)
  end

  def instantiate(clazz, properties = {})

    @resource_factory.instantiate(clazz, properties)
  end

  def get_resource(href, clazz)

    q_href = href

    if needs_to_be_fully_qualified q_href
      q_href = qualify q_href
    end

    data = execute_request('get', q_href, nil)
    @resource_factory.instantiate(clazz, data.to_hash)

  end

  def create parent_href, resource, return_type

    returned_resource = save_resource parent_href, resource, return_type

    if resource.kind_of? return_type

      resource.set_properties to_hash(returned_resource)

    end

    returned_resource

  end

  def save resource, *clazz
    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource, resource, "resource argument must be instance of Stormpath::Resource"

    href = resource.get_href
    assert_true href.length > 0, "save may only be called on objects that have already been persisted (i.e. they have an existing href)."

    if needs_to_be_fully_qualified(href)
      href = qualify(href)
    end

    clazz = (clazz.nil? or clazz.length == 0) ? to_class_from_instance(resource) : clazz[0]

    return_value = save_resource href, resource, clazz

    #ensure the caller's argument is updated with what is returned from the server:
    resource.set_properties to_hash(return_value)

    return_value

  end

  def delete resource

    assert_not_nil resource, "resource argument cannot be null."
    assert_kind_of Stormpath::Resource, resource, "resource argument must be instance of Stormpath::Resource"

    execute_request('delete', resource.get_href, nil)

  end

  protected

  def needs_to_be_fully_qualified href
    !href.downcase.start_with? 'http'
  end

  def qualify href

    slash_added = ''

    if !href.start_with? '/'
      slash_added = '/'
    end

    @base_url + slash_added + href
  end

  private

  def execute_request(http_method, href, body)

    request = Request.new(http_method, href, nil, Hash.new, body)
    apply_default_request_headers request
    response = @request_executor.execute_request request

    result = response.body.length > 0 ? MultiJson.load(response.body) : ''

    if response.error?
      error = Stormpath::ErrorResource.new result
      raise Stormpath::ResourceError.new error
    end

    result
  end

  def apply_default_request_headers request

    request.http_headers.store 'Accept', 'application/json'
    request.http_headers.store 'User-Agent', 'Stormpath-RubySDK/' + Stormpath::VERSION

    if !request.body.nil? and request.body.length > 0
      request.http_headers.store 'Content-Type', 'application/json'
    end
  end

  def save_resource href, resource, return_type

    assert_not_nil resource, "resource argument cannot be null."
    assert_not_nil return_type, "returnType class cannot be null."
    assert_kind_of Stormpath::Resource, resource, "resource argument must be instance of Stormpath::Resource"

    q_href = href

    if needs_to_be_fully_qualified q_href
      q_href = qualify q_href
    end

    response = execute_request('post', q_href, MultiJson.dump(to_hash(resource)))
    @resource_factory.instantiate(return_type, response.to_hash)

  end

  def get_base_url *base_url
    (!base_url.empty? and !base_url[0].nil?) ?
      base_url[0] :
      "https://" + DEFAULT_SERVER_HOST + "/v" + DEFAULT_API_VERSION.to_s
  end

  def to_hash resource

    property_names = resource.get_property_names
    properties = Hash.new

    property_names.each do |name|

      property = resource.get_property name

      if property.kind_of? Hash

        property = to_simple_reference name, property

      end

      properties.store name, property

    end

    properties

  end

  def to_simple_reference property_name, hash

    href_prop_name = Stormpath::Resource::HREF_PROP_NAME
    assert_true (hash.kind_of? Hash and !hash.empty? and hash.has_key? href_prop_name), "Nested resource " +
      "'#{property_name}' must have an 'href' property."

    href = hash[href_prop_name]

    {href_prop_name => href}

  end

end
