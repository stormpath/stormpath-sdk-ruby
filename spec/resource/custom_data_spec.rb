require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do
  after do
    directory.delete if directory
  end

  context 'wuth caching regions' do
    let(:directory) { test_api_client.directories.create(directory_attrs) }

    it_behaves_like 'account_custom_data'
    it_behaves_like 'group_custom_data'
  end

  context 'without caching regions' do
    let(:disabled_cache_client) do
      @disabled_cache_client ||= Stormpath::Client.new({api_key: test_api_key, cache: { store: Stormpath::Cache::DisabledCacheStore }})
    end

    let(:directory) { disabled_cache_client.directories.create(directory_attrs) }

    it_behaves_like 'account_custom_data'
    it_behaves_like 'group_custom_data'
  end
end
