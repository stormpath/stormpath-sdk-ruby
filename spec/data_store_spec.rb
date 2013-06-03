require 'spec_helper'

describe Stormpath::DataStore do
  let(:factory)           { Stormpath::Test::ResourceFactory.new }
  let(:request_executor)  { Stormpath::Test::TestRequestExecutor.new }
  let(:data_store)        { Stormpath::DataStore.new request_executor, {}, nil, nil }
  let(:application_cache) { data_store.cache_manager.get_cache 'applications' }
  let(:tenant_cache)      { data_store.cache_manager.get_cache 'tenants' }
  let(:group_cache)       { data_store.cache_manager.get_cache 'groups' }

  describe '.region_for' do
    let(:region) { data_store.send(:region_for, 'https://api.stormpath.com/v1/directories/4NykYrYH0OBiOOVOg8LXQ5') }
    it 'pulls resource name from href' do
      expect(region).to eq('directories')
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
        @cached = application_cache.get href
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
        expect(application_cache.stats.hits).to eq(1)  # this hit is when we grab @cached
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
        @cached = application_cache.get href
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
