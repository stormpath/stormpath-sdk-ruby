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
        #@mapMarshaller = new JacksonMapMarshaller();
      end

      def instantiate(clazz, properties)

        @resourceFactory.instantiate(clazz, properties)
      end

      def load_resource(href, clazz)

        data = execute_request('get', @baseUrl + href) #TODO: check for fully qualified URLS
        @resourceFactory.instantiate(clazz, data.to_hash)

      end

      # Private methods
      private

      def execute_request(httpMethod, href)

        request = Request.new(httpMethod, href, nil, nil, nil)
        response = @requestExecutor.execute_request request
        MultiJson.load response.content
      end

      def create(parentHref, resource, returnType)

      end

      def save(resource)

      end

    end
  end

end

