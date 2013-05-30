require 'spec_helper'

describe Stormpath::Cache::CacheManager do
  let(:cache_manager) { Stormpath::Cache::CacheManager.new }
  
  describe '#region_for' do
    let(:region) { cache_manager.region_for 'https://api.stormpath.com/v1/directories/4NykYrYH0OBiOOVOg8LXQ5' }
    it 'pulls resource name from href' do
      region.should == 'directories'
    end
  end
end
