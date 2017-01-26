require 'spec_helper'

describe Stormpath::Resource::Base do
  describe '.prop_accessor' do
    context 'given property names' do
      class TestResource < Stormpath::Resource::Base
        prop_accessor :username, :given_name
      end
      let(:resource) { TestResource.new({ 'username' => 'bar', 'givenName' => 'foo' }, nil) }

      it 'generates a getter method for each property' do
        expect(resource.username).to eq('bar')
        expect(resource.given_name).to eq('foo')
      end

      it 'generates a setter for each property' do
        resource.username = 'foo'
        resource.given_name = 'bar'
        expect(resource.properties).to include('username' => 'foo')
        expect(resource.properties).to include('givenName' => 'bar')
      end
    end
  end

  describe '.non_printable' do
    context 'given property names' do
      class TestResource < Stormpath::Resource::Base
        prop_non_printable :password
      end
      let(:resource) { TestResource.new({ 'username' => 'bar', 'password' => 'P@$$w0rd' }, nil) }

      it 'marks that property as not being printable' do
        expect(resource.inspect).to include('username')
        expect(resource.inspect).to_not include('password')
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
        expect(resource.username).to eq('foo')
      end
    end
  end

  describe '#==' do
    class TestResource < Stormpath::Resource::Base; end

    context 'compared against an object of the same class' do
      let(:resource) { TestResource.new('http://foo.com/test/123') }

      context 'href matches' do
        let(:other) { TestResource.new('http://foo.com/test/123') }

        it 'passes' do
          expect(resource).to eq(other)
        end
      end

      context 'href does not match' do
        let(:other) { TestResource.new('http://foo.com/test/456') }

        it 'fails' do
          expect(resource).to_not eq(other)
        end
      end
    end

    context 'compared against an object of another class' do
      class NotAResource; end
      let(:resource) { TestResource.new('http://foo.com/test/123') }
      let(:other) { NotAResource.new }

      it 'fails' do
        expect(resource).to_not eq(other)
      end
    end
  end
end
