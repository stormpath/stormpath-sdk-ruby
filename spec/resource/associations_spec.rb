require 'spec_helper'

describe Stormpath::Resource::Associations, :vcr do
  context 'expansion' do
    let(:client) do
      # every time a client is instantiated a new cache is created, so make
      # sure we use the same client across each "it" block
      test_api_client
    end

    let(:cache_manager) do
      data_store = client.instance_variable_get '@data_store'
      cache_manager = data_store.cache_manager
    end

    let(:accounts_cache_summary) do
      cache_manager.get_cache('accounts').stats.summary
    end

    let(:directories_cache_summary) do
      cache_manager.get_cache('directories').stats.summary
    end

    let(:groups_cache_summary) do
      cache_manager.get_cache('groups').stats.summary
    end

    let(:directory) do
      client.directories.create name: 'testDirectory'
    end

    let(:group) do
      directory.groups.create name: 'someGroup'
    end

    let(:account) do
      directory.accounts.create({
        email: 'rubysdk@example.com',
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: 'rubysdk'
      })
    end

    before do
      group.add_account account
    end

    after do
      group.delete if group
      directory.delete if directory
      account.delete if account
    end

    context 'expanding a nested single resource' do
      let(:cached_account) do
        client.accounts.get account.href, { expand: 'directory' }
      end

      before do
        client.data_store.initialize_cache(Hash.new)
      end

      it 'caches the nested resource' do
        expect(cached_account.directory.name).to be
        expect(directories_cache_summary).to eq([1, 1, 0, 0])
      end
    end

    context 'expanding a nested collection resource' do
      let(:cached_account) do
        client.accounts.get account.href, { expand: 'groups' }
      end

      let(:group) do
        directory.groups.create name: 'someGroup'
      end

      before do
        client.data_store.initialize_cache(Hash.new)
      end

      it 'caches the nested resource' do
        expect(cached_account.groups.first.name).to eq(group.name)
        expect(groups_cache_summary).to eq([2, 1, 0, 0])
      end
    end

  end

end
