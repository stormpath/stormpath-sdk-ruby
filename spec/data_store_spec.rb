require 'spec_helper'

describe Stormpath::DataStore do
  let(:factory) { Stormpath::Test::ResourceFactory.new }
  let(:request_executor) { Stormpath::Test::TestRequestExecutor.new }
  let(:cache_manager) { Stormpath::Cache::CacheManager.new }
  let(:data_store) { Stormpath::DataStore.new request_executor, cache_manager, nil, nil }

  describe '#get_resource' do
    context 'shallow resource' do
      before do
        @resource = factory.resource 'application', 1, %w(tenant groups)
        @href = @resource['href']
        request_executor.response = MultiJson.dump @resource
        data_store.get_resource @href, Stormpath::Resource::Application
      end

      it 'caches a shallow resource' do
        expect(cache_manager.get_cache('applications').size).to eq(1)
        expect(cache_manager.get_cache('applications').get(@href)).to eq(@resource)
        expect(cache_manager.get_cache('tenants').size).to eq(0)
        expect(cache_manager.get_cache('groups').size).to eq(0)
      end
    end
  end
end
