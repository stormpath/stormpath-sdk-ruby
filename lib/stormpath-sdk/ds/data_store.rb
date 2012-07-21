module Stormpath

  module DataStore

    class DataStore

      include Stormpath::Http
      include Stormpath::Resource
      include Stormpath::Resource::Utils
      include Stormpath::Util::Assert

      DEFAULT_SERVER_HOST = "api.stormpath.com"

      DEFAULT_API_VERSION = 1

      def initialize(requestExecutor, baseUrl)

        assert_not_nil baseUrl, "baseUrl cannot be null"
        assert_not_nil requestExecutor, "RequestExecutor cannot be null."
        @baseUrl = baseUrl;
        @requestExecutor = requestExecutor;
        @resourceFactory = ResourceFactory.new(self)
      end

      def instantiate(clazz, properties)

        @resourceFactory.instantiate(clazz, properties)
      end

      def get_resource(href, clazz)

        qHref = href

        if (needs_to_be_fully_qualified qHref)
          qHref = qualify qHref
        end

        data = execute_request('get', qHref, nil)
        @resourceFactory.instantiate(clazz, data.to_hash)

      end

      def create parentHref, resource, returnType
        save_resource parentHref, resource, returnType
      end

      def save resource, *clazz
        assert_not_nil resource, "resource argument cannot be null."
        assert_kind_of Resource, resource, "resource argument must be instance of Resource"

        href = resource.get_href
        assert_true href.length > 0, "save may only be called on objects that have already been persisted (i.e. they have an existing href)."

        if (needs_to_be_fully_qualified(href))
          href = qualify(href)
        end

        clazz = (clazz.nil? or clazz.length == 0) ? to_class_from_instance(resource) : clazz[0]

        returnValue = save_resource href, resource, clazz

        #ensure the caller's argument is updated with what is returned from the server:
        resource.set_properties returnValue.properties

        returnValue

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

        slashAdded = ''

        if (!href.start_with? '/')
          slashAdded = '/'
        end

        @baseUrl + slashAdded + href
      end

      # Private methods
      private

      def execute_request(httpMethod, href, body)

        request = Request.new(httpMethod, href, nil, Hash.new, body)
        apply_default_request_headers request
        response = @requestExecutor.execute_request request

        result = response.body.length > 0 ? MultiJson.load(response.body) : ''

        if response.error?
          error = Error.new result
          raise ResourceError.new error
        end

        result
      end

      def apply_default_request_headers request

        request.httpHeaders.store 'Accept', 'application/json'
        request.httpHeaders.store 'User-Agent', 'Stormpath-RubySDK/' #TODO: add SDK version

        if !request.body.nil? and request.body.length > 0
          request.httpHeaders.store 'Content-Type', 'application/json'
        end
      end

      def save_resource href, resource, returnType

        assert_not_nil resource, "resource argument cannot be null."
        assert_not_nil returnType, "returnType class cannot be null."
        assert_kind_of Resource, resource, "resource argument must be instance of Resource"

        qHref = href

        if (needs_to_be_fully_qualified qHref)
          qHref = qualify qHref
        end

        response = execute_request('post', qHref, MultiJson.dump(resource.properties))
        @resourceFactory.instantiate(returnType, response.to_hash)

      end

    end

  end

end

