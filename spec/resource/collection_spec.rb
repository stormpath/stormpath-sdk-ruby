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
      let(:directory) {test_api_client.directories.create name: random_directory_name }

      let(:groups) do
        ('A'..'Z').map do |letter|
          directory.groups.create name: "#{letter}. pagination testing group "
        end
      end

      after do
        directory.delete
      end

      it 'should respond as expected with or without limits' do
        expect(groups.count).to eq(26)

        expect(directory.groups.limit(3).count).to eq(26)

        expect(directory.groups.offset(10).limit(3).count).to eq(16)

        expect(directory.groups.limit(3).offset(10).count).to eq(16)

        expect(directory.groups.count).to eq(26)

        expect(directory.groups.limit(25).count).to eq(26)

        expect(directory.groups.limit(26).count).to eq(26)

        expect(directory.groups.limit(100).count).to eq(26)

        expect(directory.groups.limit(25)).to include(groups.last)

        expect(directory.groups.offset(1).limit(25)).to include(groups.last)

        expect(directory.groups.offset(1).limit(25)).not_to include(groups.first)

        expect(directory.groups.offset(25).count).to eq(1)

        expect(directory.groups.offset(26).count).to eq(0)
      end
    end

    context 'testing limits and offsets with name checking' do
      let(:directory) {test_api_client.directories.create name: random_directory_name }

      let!(:groups) do
        ('1'..'100').map do |number|
          directory.groups.create name: number
        end
      end

      after do
        directory.delete
      end

      it 'should paginate properly' do
        expect(directory.groups.count).to eq(100)

        expect(directory.groups.map {|group| group.name }).to eq(('1'..'100').to_a.sort)

        expect(directory.groups.limit(30).count).to eq(100)

        expect(directory.groups.limit(30).current_page.size).to eq(100)

        expect(directory.groups.limit(30).offset(30).count).to eq(70)

        expect(directory.groups.limit(30).offset(30).current_page.size).to eq(100)

        expect(directory.groups.limit(30).offset(60).count).to eq(40)

        expect(directory.groups.limit(30).offset(60).current_page.size).to eq(100)

        expect(directory.groups.limit(30).offset(90).count).to eq(10)

        expect(directory.groups.limit(30).offset(90).current_page.size).to eq(100)

        expect(directory.groups.limit(30).map {|group| group.name }).to eq(('1'..'100').to_a.sort)

        expect(directory.groups.limit(30).current_page.items.map {|group| group.name }).to eq(('1'..'100').to_a.sort.first(30))

        expect(directory.groups.limit(30).offset(30).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(30))

        expect(directory.groups.limit(30).offset(30).current_page.items.map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(30).first(30))

        expect(directory.groups.limit(30).offset(60).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(60))

        expect(directory.groups.limit(30).offset(60).current_page.items.map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(60).first(30))

        expect(directory.groups.limit(30).offset(90).map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(90))

        expect(directory.groups.limit(30).offset(90).current_page.items.map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(90).first(30))

        expect(directory.groups.limit(30).offset(90).current_page.items.map {|group| group.name }).to eq(('1'..'100').to_a.sort.drop(90).first(10))

        group_count = 0
        directory.groups.each do |group|
          group_count += 1
          expect(('1'..'100').to_a).to include(group.name)
        end

        expect(group_count).to eq(100)
      end
    end

    context '#wild characters search' do
      let(:directory) {test_api_client.directories.create name: random_directory_name }

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
        expect(directory.accounts.search(username: username).count).to eq(1)
      end

      it 'should search accounts by any column (aiming at username)' do
        expect(directory.accounts.search(username).count).to eq(1)
      end

      it 'should search accounts by email' do
        expect(directory.accounts.search(email: "capt@enterprise.com").count).to eq(1)
      end

      it 'should search accounts by any column (aiming at email)' do
        expect(directory.accounts.search("capt@enterprise.com").count).to eq(1)
      end
    end

    context '#asterisk search on one attribute' do
      let(:directory) {test_api_client.directories.create name: random_directory_name }

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
        expect(directory.accounts.search(username: "*card").count).to eq(1)
      end

      it 'should search accounts by username with asterisk at the end' do
        expect(directory.accounts.search(username: "jl*").count).to eq(1)
      end

      it 'should search accounts by username with asterisk at the beginning and the end' do
        expect(directory.accounts.search(username: "*pic*").count).to eq(1)
      end
    end

    context '#asterisk search on multiple attribute' do
      let(:directory) {test_api_client.directories.create name: random_directory_name }

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
        expect(directory.accounts.search(username: "*card", email: "*enterprise.com").count).to eq(1)
      end

      it 'should search accounts by username with asterisk at the end' do
        expect(directory.accounts.search(username: "jl*", email: "capt*").count).to eq(1)
      end

      it 'should search accounts by username with asterisk at the beginning and the end' do
        expect(directory.accounts.search(username: "*pic*", email: "*enterprise*").count).to eq(1)
      end
    end

  end

end
