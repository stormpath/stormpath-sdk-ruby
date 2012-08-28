require "test/resource/test_resource"

describe "READ Operations" do

  it "non materialized resource get dirty property without materializing" do

    props = {'href' => 'http://foo.com/test/123'}
    data_store = Stormpath::DataStore::DataStore.new '', ''

    test_resource = TestResource.new data_store, props
    name = 'New Name'
    test_resource.set_name name

    p test_resource

    begin

      name.should == test_resource.get_name

    rescue Exception => e

      true.should be false

    end

  end

end