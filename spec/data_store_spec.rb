require 'spec_helper'

shared_examples 'a data store' do
  let(:factory)           { Stormpath::Test::ResourceFactory.new }
  let(:request_executor)  { Stormpath::Test::TestRequestExecutor.new }
  let(:data_store) do
    Stormpath::DataStore.new(request_executor, test_api_key, store, nil)
  end
  let(:cache_manager) { data_store.cache_manager }
  let(:application_cache) { data_store.cache_manager.get_cache('applications') }
  let(:tenant_cache)      { data_store.cache_manager.get_cache('tenants') }
  let(:group_cache)       { data_store.cache_manager.get_cache('groups') }
  let(:default_base_url) { Stormpath::DataStore::DEFAULT_BASE_URL }

  after do
    application_cache.clear
  end

  describe '.region_for' do
    it 'pulls resource name from href' do
      region = cache_manager.send :region_for, "#{default_base_url}/directories/4NykYrYH0OBiOOVOg8LXQ5"
      expect(region).to eq(:directories)
    end

    it 'pulls resource name from href if its custom data also' do
      region = cache_manager.send(
        :region_for,
        "#{default_base_url}/v1/accounts/7jWpcEVSgawKkAZp8XDIEw/customData"
      )
      expect(region).to eq(:customData)
    end
  end

  describe 'custom data regex matchers' do
    let(:custom_data_url_regex) { cache_manager.send(:custom_data_url_regex, default_base_url) }
    context 'CUSTOM_DATA_DELETE_FIELD_REGEX' do
      it 'should match custom data field href' do
        expect("#{default_base_url}/accounts/2f8U7r5JweVf1ZTtcJ08L8/customData/rank")
          .to match(custom_data_url_regex)

        expect("#{default_base_url}/groups/4x6vwucf1w9wjHvt7paGoY/customData/rank")
          .to match(custom_data_url_regex)
      end

      it 'should not match custom data resource href' do
        expect("#{default_base_url}/accounts/2f8U7r5JweVf1ZTtcJ08L8/customData")
          .not_to match(custom_data_url_regex)

        expect("#{default_base_url}/groups/4x6vwucf1w9wjHvt7paGoY/customData")
          .not_to match(custom_data_url_regex)
      end
    end
  end

  describe '#delete' do
    before do
      resource = factory.resource 'application', 1, %w(tenant groups)
      href = resource['href']
      request_executor.response = MultiJson.dump resource
      application = data_store.get_resource href, Stormpath::Resource::Application
      expect(application_cache.size).to eq(1)
      data_store.delete application
    end

    it 'removes the resource from the cache' do
      expect(application_cache.size).to be(0)
    end
  end

  describe '#get_resource' do
    context 'shallow resource' do
      before do
        resource = factory.resource 'application', 1, %w(tenant groups)
        href = resource['href']
        request_executor.response = MultiJson.dump resource
        data_store.get_resource href, Stormpath::Resource::Application
        @cached = application_cache.get(href)
      end

      it 'caches a shallow resource' do
        expect(@cached).to be
        expect(@cached).to be_resource
        expect(@cached['tenant']).to be_link
        expect(@cached['groups']).to be_link_collection
      end

      it 'caches no associations' do
        expect(tenant_cache.size).to eq(0)
        expect(group_cache.size).to eq(0)
      end

      it 'misses the cache on the get' do
        expect(application_cache.stats.hits).to eq(1) # this hit is when we grab @cached
        expect(application_cache.stats.misses).to eq(1)
      end

      context 'retrieved twice' do
        before do
          data_store.get_resource @cached['href'], Stormpath::Resource::Application
        end

        it 'hits the cache on the get' do
          expect(application_cache.stats.hits).to eq(2)
          expect(application_cache.stats.misses).to eq(1)
        end
      end
    end

    context 'deep resource' do
      before do
        resource = factory.resource 'application', 2, %w(tenant groups)
        href = resource['href']
        request_executor.response = MultiJson.dump resource
        data_store.get_resource href, Stormpath::Resource::Application
        @cached = application_cache.get(href)
      end

      it 'caches a shallow resource' do
        expect(@cached).to be
        expect(@cached).to be_resource
        expect(@cached['tenant']).to be_link
        expect(@cached['groups']).to be_link_collection
      end

      it 'caches shallow associations' do
        expect(tenant_cache.size).to eq(1)
        expect(group_cache.size).to eq(2)
      end
    end

    context 'shallow collection' do
      before do
        resource = factory.collection 'tenant', 'application', 1, %w(tenant groups)
        href = resource['href']
        request_executor.response = MultiJson.dump resource
        data_store.get_resource href, Stormpath::Resource::Application
      end

      it 'caches collection resources only' do
        expect(application_cache.size).to eq(2)
        expect(tenant_cache.size).to eq(0)
        expect(group_cache.size).to eq(0)
      end
    end

    context 'deep collection' do
      before do
        resource = factory.collection 'tenant', 'application', 2, %w(tenant groups)
        href = resource['href']
        request_executor.response = MultiJson.dump resource
        data_store.get_resource href, Stormpath::Resource::Application
      end

      it 'caches collection resources and associations' do
        expect(application_cache.size).to eq(2)
        expect(tenant_cache.size).to eq(2)
        expect(group_cache.size).to eq(4)
      end
    end
  end
end

describe Stormpath::DataStore do
  context 'redis store' do
    let(:store) { { store: Stormpath::Cache::RedisStore, store_opts: { read_timeout: 6.0 } } }
    it_should_behave_like 'a data store'
  end

  context 'memcached store' do
    let(:store) do
      {
        store: Stormpath::Cache::MemcachedStore,
        store_opts: { host: 'localhost:11211', prefix_key: 'mem' }
      }
    end
    it_should_behave_like 'a data store'
  end
end
