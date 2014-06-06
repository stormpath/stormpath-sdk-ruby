require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do
  let(:directory) { test_api_client.directories.create name: 'test_directory' }

  after do
    directory.delete if directory
  end

  context 'wuth caching regions' do
    it_behaves_like 'account_custom_data'
    it_behaves_like 'group_custom_data'
  end

  context 'without caching regions' do
    before(:all) do
      Stormpath::DataStore.send :remove_const, :CACHE_REGIONS
      Stormpath::DataStore.const_set :CACHE_REGIONS, %w(applications directories accounts groups groupMemberships accountMemberships tenants)
    end

    it_behaves_like 'account_custom_data'
    it_behaves_like 'group_custom_data'

    after(:all) do
      Stormpath::DataStore.send :remove_const, :CACHE_REGIONS
      Stormpath::DataStore.const_set :CACHE_REGIONS, %w(applications directories accounts groups groupMemberships accountMemberships tenants customData)
    end
  end
end
