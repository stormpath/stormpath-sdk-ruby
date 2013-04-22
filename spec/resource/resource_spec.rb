require 'stormpath-sdk'

describe "Resource Tests" do

  context "given something rudy will type" do
    class TestResource < Stormpath::Resource

      def name
        get_property 'name'
      end

      def name=(name)
        set_property 'name', name
      end

      def description
        get_property 'description'
      end

      def description=(description)
        set_property 'description', description
      end

      def password=(password)
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
        test_resource.name = name

        begin

          name.should == test_resource.name

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
        test_resource.name = name

        test_resource.password = 'my_password'

        test_resource.inspect.should_not include 'password'

      end
    end

  end
end
