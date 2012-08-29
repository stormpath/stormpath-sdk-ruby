require "test/resource/test_resource"

describe "Resource Tests" do

  it "non materialized resource get dirty property without materializing" do

    props = {'href' => 'http://foo.com/test/123'}
    data_store = Stormpath::DataStore::DataStore.new '', ''

    test_resource = TestResource.new data_store, props
    name = 'New Name'
    test_resource.set_name name

    begin

      name.should == test_resource.get_name

    rescue Exception => e

      true.should be false

    end

  end

  it "password property must not show up on inspect" do

    props = {'href' => 'http://foo.com/test/123'}
    data_store = Stormpath::DataStore::DataStore.new '', ''

    test_resource = TestResource.new data_store, props
    name = 'New Name'
    test_resource.set_name name

    test_resource.set_password 'my_password'

    test_resource.inspect.should_not include 'password'

  end

end