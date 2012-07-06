require "stormpath-sdk/ds/data_store"
require "stormpath-sdk/http/http_client_request_executor"
require "stormpath-sdk/resource/tenant"

module Stormpath

  module Client

    include Stormpath::Http
    include Stormpath::DataStore

    class Client

      attr_reader :dataStore

      def initialize(apiKey, baseUrl)
        requestExecutor = HttpClientRequestExecutor.new(apiKey)
        @dataStore = DataStore::DataStore.new(requestExecutor, baseUrl)
      end


      def current_tenant
        @dataStore.load_resource("/tenants/current", Tenant)
      end
    end
  end


end

