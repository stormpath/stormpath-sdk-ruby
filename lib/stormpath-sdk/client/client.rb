module Stormpath

  module Client

    class Client

      attr_reader :data_store

      def initialize(api_key, *base_url)
        request_executor = Stormpath::Http::HttpClientRequestExecutor.new(api_key)
        @data_store = Stormpath::DataStore::DataStore.new(request_executor, *base_url)
      end


      def current_tenant
        @data_store.get_resource("/tenants/current", Stormpath::Resource::Tenant)
      end
    end
  end


end

