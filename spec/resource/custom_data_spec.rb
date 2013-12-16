 # test_api_client.accounts.get "https://api.stormpath.com/v1/accounts/1SmmWv659tY9Eeb4qKZqr0"
require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do
  describe "#for accounts" do
    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:account) do
      directory.accounts.create email: 'jabba.hutt@example.com',
        givenName: 'Jabba',
        password: 'Jabba123!',
        surname: 'The Hutt',
        username: 'Jabba The Hutt'
    end

    let(:reloaded_account) { test_api_client.accounts.get account.href }

    after do
      account.delete if account
      directory.delete if directory
    end
    
    it 'read reserved data' do
      expect(account.custom_data.get("href")).not_to eq(nil)
      expect(account.custom_data.get("created_at")).not_to eq(nil)
      expect(account.custom_data.get("modified_at")).not_to eq(nil)
    end

    it 'set custom data' do
      account.custom_data.put(:vehicle, "Sail barge")
      expect(account.custom_data.get(:vehicle)).to eq("Sail barge")
      account.custom_data.save
      expect(reloaded_account.custom_data.get(:vehicle)).to eq("Sail barge")
    end

    it 'not raise errors when saving a empty properties array' do
      account.custom_data.save
    end

    it 'trigger custom data saving on account.save' do
      account.custom_data.put(:vehicle, "Sail barge")
      account.surname = "Hutt"
      account.save
      expect(reloaded_account.surname).to eq("Hutt")
      expect(reloaded_account.custom_data.get(:vehicle)).to eq("Sail barge")
    end

    it 'delete all custom data' do
      account.custom_data.put("vehicle", "Sail barge")
      account.custom_data.save
      expect(account.custom_data.get("vehicle")).to eq("Sail barge")
      account.custom_data.delete
      expect(reloaded_account.custom_data.get("vehicle")).to eq(nil)
    end

    it 'delete a specific custom data field' do
      account.custom_data.put("vehicle", "Sail barge")
      account.custom_data.put("homeworld", "Tatooine")
      account.custom_data.save
      
      account.custom_data.delete("vehicle")
      expect(reloaded_account.custom_data.get("vehicle")).to eq(nil)
      expect(reloaded_account.custom_data.get("homeworld")).to eq("Tatooine")
    end
  end

  describe "#for groups" do
    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:group) { directory.groups.create name: 'Duality' }

    let(:reloaded_group) { test_api_client.groups.get group.href }

    after do
      group.delete if group
      directory.delete if directory
    end
    
    it 'read reserved data' do
      expect(group.custom_data.get("href")).not_to eq(nil)
      expect(group.custom_data.get("created_at")).not_to eq(nil)
      expect(group.custom_data.get("modified_at")).not_to eq(nil)
    end

    it 'set custom data' do
      group.custom_data.put(:cult, "Tarrack")
      expect(group.custom_data.get(:cult)).to eq("Tarrack")
      group.custom_data.save
      expect(reloaded_group.custom_data.get(:cult)).to eq("Tarrack")
    end

    it 'not raise errors when saving a empty properties array' do
      group.custom_data.save
    end

    it 'trigger custom data saving on group.save' do
      group.custom_data.put(:cult, "Tarrack")
      group.description = "founded on the twin principles of joy and service"
      group.save
      expect(reloaded_group.description).to eq("founded on the twin principles of joy and service")
      expect(reloaded_group.custom_data.get(:cult)).to eq("Tarrack")
    end

    it 'delete all custom data' do
      group.custom_data.put("cult", "Tarrack")
      group.custom_data.save
      expect(group.custom_data.get("cult")).to eq("Tarrack")
      group.custom_data.delete
      expect(reloaded_group.custom_data.get("cult")).to eq(nil)
    end

    it 'delete a specific custom data field' do
      group.custom_data.put("cult", "Tarrack")
      group.custom_data.put("homeworld", "Tatooine")
      group.custom_data.save
      
      group.custom_data.delete("cult")
      expect(reloaded_group.custom_data.get("cult")).to eq(nil)
      expect(reloaded_group.custom_data.get("homeworld")).to eq("Tatooine")
    end
  end

end
