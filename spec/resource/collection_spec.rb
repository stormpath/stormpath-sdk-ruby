require 'spec_helper'

describe Stormpath::Resource::Collection, :vcr do
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

  context 'live examples' do
    context 'testing limits and offsets' do
      let(:directory) {test_api_client.directories.create name: "Directory for pagination testing"}

      let(:groups) do
        ('A'..'Z').map do |letter|
          directory.groups.create name: "#{letter}. pagination testing group "
        end
      end

      after do
        directory.delete
      end

      it 'should respond as expected with or without limits' do
        expect(groups).to have(26).items

        expect(directory.groups.limit(3)).to have(26).items

        expect(directory.groups.offset(10).limit(3)).to have(16).items

        expect(directory.groups.limit(3).offset(10)).to have(16).items

        expect(directory.groups).to have(26).items

        expect(directory.groups.limit(25)).to have(26).items

        expect(directory.groups.limit(26)).to have(26).items

        expect(directory.groups.limit(100)).to have(26).items

        expect(directory.groups.limit(25)).to include(groups.last)

        expect(directory.groups.offset(1).limit(25)).to include(groups.last)

        expect(directory.groups.offset(1).limit(25)).not_to include(groups.first)

        expect(directory.groups.offset(25)).to have(1).items

        expect(directory.groups.offset(26)).to have(0).items
      end
    end

    context 'testing limits and offsets with name checking' do
      let(:directory) {test_api_client.directories.create name: "Directory for pagination testing"}

      let!(:groups) do
        ('1'..'100').map do |number|
          directory.groups.create name: number
        end
      end

      after do
        directory.delete
      end

      it 'should paginate properly' do
        expect(directory.groups).to have(100).items

        expect(directory.groups.map {|group| group.name }).to eq(('1'..'100').to_a.sort)

        expect(directory.groups.limit(30)).to have(100).items

        expect(directory.groups.limit(30).offset(30)).to have(70).items

        expect(directory.groups.limit(30).offset(60)).to have(40).items

        expect(directory.groups.limit(30).offset(90)).to have(10).items

        expect(directory.groups.limit(30).map {|group| group.name }).to eq(('1'..'100').to_a.sort)

        expect(directory.groups.limit(30).offset(30).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(30))

        expect(directory.groups.limit(30).offset(60).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(60))

        expect(directory.groups.limit(30).offset(90).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(90))

        group_count = 0
        directory.groups.each do |group|
          group_count += 1
          expect(('1'..'100').to_a).to include(group.name)
        end

        expect(group_count).to eq(100)
      end
    end

    context '#wild characters search' do
      let(:directory) {test_api_client.directories.create name: "Test directory"}

      # !@#$%^&*()_-+=?><:]}[{'
      # 'jlpicard/!@$%^*()_-+&=?><:]}[{'
      let(:username) { 'jlpicard/!@$%^ *()_-+=?><:]}[{' }

      let!(:account) do
        directory.accounts.create username: username,
           email: "capt@enterprise.com",
           givenName: "Jean-Luc",
           surname: "Picard",
           password: "hakunaMatata179Enterprise"
      end

      after do
        directory.delete
      end

      it 'should search accounts by username' do
        expect(directory.accounts.search(username: username)).to have(1).items
      end

      it 'should search accounts by any column (aiming at username)' do
        expect(directory.accounts.search(username)).to have(1).items
      end

      it 'should search accounts by email' do
        expect(directory.accounts.search(email: "capt@enterprise.com")).to have(1).items
      end

      it 'should search accounts by any column (aiming at email)' do
        expect(directory.accounts.search("capt@enterprise.com")).to have(1).items
      end
    end

    context '#asterisk search on one attribute' do
      let(:directory) {test_api_client.directories.create name: "Test directory"}

      let!(:account) do
        directory.accounts.create username: "jlpicard",
           email: "capt@enterprise.com",
           givenName: "Jean-Luc",
           surname: "Picard",
           password: "hakunaMatata179Enterprise"
      end

      after do
        directory.delete
      end

      it 'should search accounts by username with asterisk at the beginning' do
        expect(directory.accounts.search(username: "*card")).to have(1).items
      end

      it 'should search accounts by username with asterisk at the end' do
        expect(directory.accounts.search(username: "jl*")).to have(1).items
      end

      it 'should search accounts by username with asterisk at the beginning and the end' do
        expect(directory.accounts.search(username: "*pic*")).to have(1).items
      end
    end

    context '#asterisk search on multiple attribute' do
      let(:directory) {test_api_client.directories.create name: "Test directory"}

      let!(:account) do
        directory.accounts.create username: "jlpicard",
           email: "capt@enterprise.com",
           givenName: "Jean-Luc",
           surname: "Picard",
           password: "hakunaMatata179Enterprise"
      end

      after do
        directory.delete
      end

      it 'should search accounts by username with asterisk at the beginning' do
        expect(directory.accounts.search(username: "*card", email: "*enterprise.com")).to have(1).items
      end

      it 'should search accounts by username with asterisk at the end' do
        expect(directory.accounts.search(username: "jl*", email: "capt*")).to have(1).items
      end

      it 'should search accounts by username with asterisk at the beginning and the end' do
        expect(directory.accounts.search(username: "*pic*", email: "*enterprise*")).to have(1).items
      end
    end

  end

end
