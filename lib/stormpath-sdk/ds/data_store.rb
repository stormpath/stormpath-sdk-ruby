module Stormpath

  module DataStore

    class DataStore

      include Stormpath::Http
      include Stormpath::Resource
      include Stormpath::Resource::Utils
      include Stormpath::Util::Assert

      DEFAULT_SERVER_HOST = "api.stormpath.com"

      DEFAULT_API_VERSION = 1

      def initialize(request_executor, *base_url)

        assert_not_nil request_executor, "RequestExecutor cannot be null."
        @base_url = get_base_url *base_url
        @request_executor = request_executor
        @resource_factory = ResourceFactory.new(self)
      end

      def instantiate(clazz, properties)

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
        save_resource parent_href, resource, return_type
      end

      def save resource, *clazz
        assert_not_nil resource, "resource argument cannot be null."
        assert_kind_of Resource, resource, "resource argument must be instance of Resource"

        href = resource.get_href
        assert_true href.length > 0, "save may only be called on objects that have already been persisted (i.e. they have an existing href)."

        if needs_to_be_fully_qualified(href)
          href = qualify(href)
        end

        clazz = (clazz.nil? or clazz.length == 0) ? to_class_from_instance(resource) : clazz[0]

        return_value = save_resource href, resource, clazz

        #ensure the caller's argument is updated with what is returned from the server:
        resource.set_properties return_value.properties

        return_value

      end

      def delete resource

        assert_not_nil resource, "resource argument cannot be null."
        assert_kind_of Resource, resource, "resource argument must be instance of Resource"

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
          error = Error.new result
          raise ResourceError.new error
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
        assert_kind_of Resource, resource, "resource argument must be instance of Resource"

        q_href = href

        if needs_to_be_fully_qualified q_href
          q_href = qualify q_href
        end

        response = execute_request('post', q_href, MultiJson.dump(resource.properties))
        @resource_factory.instantiate(return_type, response.to_hash)

      end

      def get_base_url *base_url
        (!base_url.empty? and !base_url[0].nil?) ?
            base_url[0] :
            "https://" + DEFAULT_SERVER_HOST + "/v" + DEFAULT_API_VERSION.to_s
      end

    end

  end

end

