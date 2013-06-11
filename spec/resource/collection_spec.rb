require 'spec_helper'

describe Stormpath::Resource::Collection do
  let(:href) do
    'http://example.com'
  end

  let(:item_class) do
    Stormpath::Resource::Application
  end

  let(:client) do
    Stormpath::Client
  end

  describe '#collection_href' do
    context 'by default' do
      let(:collection) do
        Stormpath::Resource::Collection.new href, item_class, client
      end

      it 'defaults to href' do
        expect(collection.collection_href).to eq href
      end
    end

    context 'when specified' do
      let(:collection_href) do
        'http://fakie.com'
      end

      let(:collection) do
        Stormpath::Resource::Collection.new(
          href, item_class, client,
          collection_href: collection_href
        )
      end

      it 'defaults to href' do
        expect(collection.collection_href).to eq collection_href
      end
    end
  end

  describe '#offset' do
    let(:collection) do
      Stormpath::Resource::Collection.new href, item_class, client
    end

    let!(:offset) do
      collection.offset 5
    end

    it 'returns the collection' do
      expect(offset.class).to eq Stormpath::Resource::Collection
    end

    it 'adds the query to the criteria' do
      expect(collection.criteria).to include offset: 5
    end
  end

  describe '#limit' do
    let(:collection) do
      Stormpath::Resource::Collection.new href, item_class, client
    end

    let!(:limit) do
      collection.limit 100
    end

    it 'returns the collection' do
      expect(limit.class).to eq Stormpath::Resource::Collection
    end

    it 'adds the query param to the criteria' do
      expect(collection.criteria).to include limit: 100
    end
  end

  describe '#order' do
    let(:collection) do
      Stormpath::Resource::Collection.new href, item_class, client
    end

    let(:order_statement) do
      'lastName asc,age desc'
    end

    let!(:order) do
      collection.order order_statement
    end

    it 'returns the collection' do
      expect(order.class).to eq Stormpath::Resource::Collection
    end

    it 'adds the query param to the criteria' do
      expect(collection.criteria).to include order_by: order_statement
    end
  end

  describe '#search' do
    let(:collection) do
      Stormpath::Resource::Collection.new href, item_class, client
    end

    context 'when passed a string' do
      let(:query) do
        'dagnabbit'
      end

      let!(:search) do
        collection.search query
      end

      it 'returns the collection' do
        expect(search.class).to eq Stormpath::Resource::Collection
      end

      it 'adds a "q" query string to the criteria' do
        expect(collection.criteria).to include q: query
      end
    end

    context 'when passed a hash of attributes' do
      let(:query_hash) do
        { name: 'Stanley Kubrick', description: 'That dude was a sick maniac' }
      end

      let!(:search) do
        collection.search query_hash
      end

      it 'returns the collection' do
        expect(search.class).to eq Stormpath::Resource::Collection
      end

      it 'adds a "q" query string to the criteria' do
        expect(collection.criteria).to include query_hash
      end
    end
  end

  describe '#criteria' do
    let(:collection) do
      Stormpath::Resource::Collection.new href, item_class, client
    end

    context 'when no fetch criteria present' do
      it 'returns an empty hash for criteria' do
        expect(collection.criteria).to be_empty
      end
    end

    context 'when search, offset, limit and order by are chained' do
      before do
        collection.search('Big up to Brooklyn').order('lastName asc').offset(15).limit 50
      end

      it 'has the search parameters' do
        expect(collection.criteria).to include q: 'Big up to Brooklyn'
        expect(collection.criteria).to include offset: 15
        expect(collection.criteria).to include limit: 50
        expect(collection.criteria).to include order_by: 'lastName asc'
      end
    end
  end
end
