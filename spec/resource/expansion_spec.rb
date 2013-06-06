require 'spec_helper'

describe Stormpath::Resource::Expansion, :vcr do
  describe '#initialize' do
    context 'given a single property name' do
      let(:expansion) do
        Stormpath::Resource::Expansion.new 'foo'
      end

      it 'can be transmuted to a simple hash' do
        expect(expansion.to_query).to eq({ expand: 'foo' })
      end
    end
    context 'given a list of property names' do
      let(:expansion) do
        Stormpath::Resource::Expansion.new 'foo', 'bar'
      end

      it 'can be transmuted to a simple hash' do
        expect(expansion.to_query).to eq({ expand: 'foo,bar' })
      end
    end

    context 'given no arguments are passed to constructor' do
      let(:expansion) do
        Stormpath::Resource::Expansion.new
      end

      it 'will transmute to an empty hash' do
        expect(expansion.to_query).to be_nil
      end
    end
  end

  describe "#add_property" do
    context 'given a simple property name' do
      let(:expansion) { Stormpath::Resource::Expansion.new }

      before do
        expansion.add_property :foo
      end

      it 'can be transmuted to a simple hash' do
        expect(expansion.to_query).to eq({ expand: 'foo' })
      end
    end

    context 'given two simple property names' do
      let(:expansion) { Stormpath::Resource::Expansion.new }

      before do
        expansion.add_property :foo
        expansion.add_property :bar
      end

      it 'can be transmuted to a simple hash' do
        expect(expansion.to_query).to eq({ expand: 'foo,bar' })
      end
    end

    context 'given a duplicate property name' do
      let(:expansion) { Stormpath::Resource::Expansion.new }

      before do
        expansion.add_property :foo
        expansion.add_property :bar
        expansion.add_property :bar
      end

      it 'will not duplicate the property' do
        expect(expansion.to_query).to eq({ expand: 'foo,bar' })
      end
    end

    context 'given a property name, offset, and limit' do
      let(:expansion) { Stormpath::Resource::Expansion.new }

      before do
        expansion.add_property :foo, offset: 5, limit: 100
      end

      it 'can be transmuted to a simple hash' do
        expect(expansion.to_query).to eq({ expand: 'foo(offset:5,limit:100)' })
      end
    end

    context 'given two calls to add the same property' do
      let(:expansion) { Stormpath::Resource::Expansion.new }

      before do
        expansion.add_property :foo, offset: 5, limit: 100
        expansion.add_property :foo, offset: 25
      end

      it 'allows the last call to win out over the first' do
        expect(expansion.to_query).to eq({ expand: 'foo(offset:25)' })
      end
    end
  end
end
