require "stormpath-sdk/ds/data_store"
require "stormpath-sdk/http/http_client_request_executor"
require "stormpath-sdk/tenant/tenant"

class Client

  attr_reader :dataStore

  def initialize(apiKey, baseUrl)
    requestExecutor = HttpClientRequestExecutor.new(apiKey)
    @dataStore = DataStore.new(requestExecutor, baseUrl)
  end


  def current_tenant
    @dataStore.load("/tenants/current", Tenant)
  end
end