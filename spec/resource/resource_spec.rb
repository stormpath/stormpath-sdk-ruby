require 'stormpath-sdk'

describe "Resource Tests" do

  context "given something rudy will type" do
    class TestResource < Stormpath::Resource

      def get_name
        get_property 'name'
      end

      def set_name name
        set_property 'name', name
      end

      def get_description
        get_property 'description'
      end

      def set_description description
        set_property 'description', description
      end

      def set_password password
        set_property 'password', password
      end

      protected
      def printable_property? property_name
        'password' != property_name
      end

    end

    context 'when the resource is non-materialized' do
      it "gets dirty property without materializing" do
        props = {'href' => 'http://foo.com/test/123'}
        data_store = Stormpath::DataStore.new '', ''

        test_resource = TestResource.new data_store, props
        name = 'New Name'
        test_resource.set_name name

        begin

          name.should == test_resource.get_name

        rescue Exception => e

          true.should be false

        end

      end
    end

    context 'when inspecting a resource' do
      it "does NOT show the password property" do

        props = {'href' => 'http://foo.com/test/123'}
        data_store = Stormpath::DataStore.new '', ''

        test_resource = TestResource.new data_store, props
        name = 'New Name'
        test_resource.set_name name

        test_resource.set_password 'my_password'

        test_resource.inspect.should_not include 'password'

      end
    end

  end
end
