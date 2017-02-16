require 'spec_helper'

shared_examples 'a cache manager' do
  it 'should successfully initialize' do
    expect(manager).to be
  end

  it 'should contain all default cache regions' do
    expect(manager.stats.keys).to eq default_cache_regions
  end
end

describe Stormpath::Cache::CacheManager, vcr: true do
  let(:base_url) { 'http://api.stormpath.com/v1' }
  let(:manager) { Stormpath::Cache::CacheManager.new(base_url, cache_opts) }
  let(:default_cache_regions) { Stormpath::Cache::CacheManager::CACHE_REGIONS }
  let(:default_store) { Stormpath::Cache::MemoryStore }
  let(:redis_store) { Stormpath::Cache::RedisStore }
  let(:cache_opts) do
    {
      regions: custom_region_opts,
      store: store,
      store_opts: store_opts
    }
  end
  let(:custom_region_opts) { nil }
  let(:store) { nil }
  let(:store_opts) { nil }

  describe 'initialization' do
    context 'empty options' do
      it_should_behave_like 'a cache manager'
    end

    context 'custom region options' do
      let(:custom_region_opts) { { applications: { tti_seconds: 100 } } }

      it 'should set the application region tti_seconds' do
        expect(manager.get_cache(:applications).tti_seconds).to eq 100
      end

      it 'should have the default tti_seconds for directories' do
        expect(manager.get_cache(:directories).tti_seconds).to eq 300
      end

      it_should_behave_like 'a cache manager'
    end

    context 'custom store on all regions' do
      let(:store) { Stormpath::Cache::RedisStore }

      it 'should set custom store' do
        expect(manager.get_cache(:applications).store.class).to eq store
      end

      it_should_behave_like 'a cache manager'
    end

    context 'custom store on directories region' do
      let(:custom_region_opts) { { directories: { store: redis_store } } }

      it 'should set custom store' do
        expect(manager.get_cache(:directories).store.class).to eq redis_store
        expect(manager.get_cache(:applications).store.class).to eq default_store
      end

      it_should_behave_like 'a cache manager'
    end
  end

  describe 'stats' do
    let(:application_cache_stats) { get_cache_data(application.href).stats.summary }

    it 'should return the region stats' do
      expect(manager.stats[:applications].summary).to eq [0, 0, 0, 0, 0]
    end

    context 'when application accessed' do
      let!(:application) { test_api_client.applications.create(application_attrs) }

      it 'should have updated applications region stats' do
        expect(application_cache_stats).to eq [1, 0, 0, 0, 1]
      end
    end
  end

  describe 'cache_walk' do
    context 'single resource' do
      let(:resource) { JSON.parse(Stormpath::Test.mocked_account(:google)) }
      let(:cache_walk) { manager.cache_walk(resource) }

      it 'should affect the account stats' do
        expect { cache_walk }.to change { manager.stats[:accounts].summary }
      end

      it 'should cache the account in MemoryStore' do
        expect { cache_walk }.to change { manager.get_cache(:accounts).store.size }.from(0).to(1)
      end
    end

    context 'collection resource' do
      let(:resource) { JSON.parse(Stormpath::Test.mocked_directories_response) }
      let(:cache_walk) { manager.cache_walk(resource) }

      it 'should affect the tenants stats' do
        expect { cache_walk }.not_to change { manager.stats[:tenants].summary }
      end

      it 'should affect the directories stats' do
        expect { cache_walk }.to change { manager.stats[:directories].summary }
      end

      it 'should cache the tenant in MemoryStore' do
        expect { cache_walk }.not_to change { manager.get_cache(:tenants).store.size }
      end

      it 'should cache the directories in MemoryStore' do
        expect { cache_walk }.to change { manager.get_cache(:directories).store.size }.from(0).to(3)
      end
    end
  end

  describe 'cache_for' do
    context 'href is present' do
      let(:resource) { JSON.parse(Stormpath::Test.mocked_account(:google)) }
      let(:cache_result) { manager.cache_for(resource['href']) }
      before { manager.send(:cache_it, resource) }

      it 'should return the cache' do
        expect(cache_result).to be_a Stormpath::Cache::Cache
      end

      it 'the cache store should contain the resource where href is the key' do
        expect(cache_result.get(resource['href'])).to eq resource
      end
    end

    context 'href is blank' do
      let(:href) { '' }
      let(:cache_result) { manager.cache_for(href) }

      it 'should raise ArgumentError' do
        expect { cache_result }.to raise_error(ArgumentError, "href property can't be blank")
      end
    end

    context 'href is nil' do
      let(:href) { nil }
      let(:cache_result) { manager.cache_for(href) }

      it 'should raise ArgumentError' do
        expect { cache_result }.to raise_error(ArgumentError, "href property can't be blank")
      end
    end
  end

  describe 'clear_cache_on_delete' do
    let(:resource) { JSON.parse(Stormpath::Test.mocked_account(:google)) }
    let(:clear_cache_on_delete) { manager.clear_cache_on_delete(resource['href']) }

    before { manager.send(:cache_it, resource) }

    it 'should return nil' do
      expect(clear_cache_on_delete).to be_nil
    end

    it 'should clear cache for the resource' do
      expect { clear_cache_on_delete }.to change { manager.get_cache(:accounts).get(resource['href']) }
    end
  end

  describe 'clear_cache_on_save' do
    let(:clear_cache_on_save) { test_api_client.cache_manager.clear_cache_on_save(resource) }

    context 'custom data storage' do
      xit do
        # TODO: when can this even happen?
        # Stormpath::Resource::CustomDataStorage is a module, not a class
      end
    end

    context 'account store mapping' do
      let(:app) { test_api_client.applications.create(application_attrs) }
      let(:dir) { test_api_client.directories.create(directory_attrs) }

      after do
        dir.delete
        app.delete
      end

      context 'new account store mapping' do
        context 'default_account_store? || default_group_store? is false' do
          let(:resource) { map_account_store(app, dir, 0, false, false) }

          it 'should not clear application cache' do
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 0
            resource
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 1
          end
        end

        context 'default_account_store? || default_group_store? is true' do
          let(:resource) { map_account_store(app, dir, 0, true, true) }

          it 'should clear application cache' do
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 0
            resource
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 0
          end
        end
      end

      context 'existing account store mapping' do
        let!(:resource) { map_account_store(app, dir, 0, false, false) }

        context 'is_default_account_store is present' do
          let(:update_resource) do
            resource.is_default_account_store = true
            resource.save
          end

          it 'should clear application cache' do
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 1
            update_resource
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 0
          end
        end

        context 'is_default_group_store is present' do
          let(:update_resource) do
            resource.is_default_group_store = false
            resource.save
          end

          it 'should clear application cache' do
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 1
            update_resource
            expect(test_api_client.data_store.cache_manager.get_cache(:applications).stats.size).to eq 0
          end
        end
      end
    end
  end
end
