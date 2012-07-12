require "stormpath-sdk/ds/resource_factory"
require "stormpath-sdk/http/request"
require "multi_json"

module Stormpath

  module DataStore

    class DataStore

      String DEFAULT_SERVER_HOST = "api.stormpath.com"

      Integer DEFAULT_API_VERSION = 1

      def initialize(requestExecutor, baseUrl)


        #Assert.notNull(baseUrl, "baseUrl cannot be null");
        #Assert.notNull(requestExecutor, "RequestExecutor cannot be null.");
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

        request = Request.new(httpMethod, href, nil, nil, body)
        response = @requestExecutor.execute_request request
        MultiJson.load response.content
      end

      def save_resource href, resource, returnType

        #Assert.notNull(resource, "resource argument cannot be null.");
        #Assert.notNull(returnType, "returnType class cannot be null.");
        #Assert.isInstanceOf(AbstractResource.class, resource);

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

