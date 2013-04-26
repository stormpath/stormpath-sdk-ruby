require 'spec_helper'

describe Stormpath::Resource::Base do
  describe '.prop_accessor' do
    context 'given property names' do
      class TestResource < Stormpath::Resource::Base
        prop_accessor :username, :given_name
      end

      let(:resource) do
        TestResource.new({
          'username' => 'bar',
          'givenName' => 'foo'
        }, nil)
      end

      it 'generates a getter method for each property' do
        resource.username.should == 'bar'
        resource.given_name.should == 'foo'
      end

      it 'generates a setter for each property' do
        resource.username = 'foo'
        resource.given_name = 'bar'
        resource.properties.should include('username' => 'foo')
        resource.properties.should include('givenName' => 'bar')
      end
    end
  end

  describe '.non_printable' do
    context 'given property names' do
      class TestResource < Stormpath::Resource::Base
        prop_non_printable :password
      end

      let(:resource) do
        TestResource.new({
          'username' => 'bar',
          'password' => 'P@$$w0rd'
        }, nil)
      end

      it 'marks that property as not being printable' do
        resource.inspect.should include('username')
        resource.inspect.should_not include('password')
      end
    end
  end

  describe '.get_property' do
    context 'given the name of a dirty property' do
      class TestResource < Stormpath::Resource::Base
        prop_accessor :username
      end

      let(:resource) do
        TestResource.new('http://foo.com/test/123', nil).tap do |resource|
          resource.username = 'foo'
        end
      end

      it 'does NOT attempt to materialize the entire resource' do
        expect do
         resource.username.should == 'foo'
        end.to_not raise_exception
      end
    end
  end
end
