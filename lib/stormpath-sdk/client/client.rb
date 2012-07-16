module Stormpath

  module Client

    class Client

      attr_reader :dataStore

      def initialize(apiKey, baseUrl)
        requestExecutor = Stormpath::Http::HttpClientRequestExecutor.new(apiKey)
        @dataStore = Stormpath::DataStore::DataStore.new(requestExecutor, baseUrl)
      end


      def current_tenant
        @dataStore.get_resource("/tenants/current", Stormpath::Resource::Tenant)
      end
    end
  end


end

