 # test_api_client.accounts.get "https://api.stormpath.com/v1/accounts/1SmmWv659tY9Eeb4qKZqr0"
require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do
  describe "#for accounts" do
    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:account) do
      directory.accounts.create username: "jlpicard",
         email: "capt@enterprise.com",
         givenName: "Jean-Luc",
         surname: "Picard",
         password: "uGhd%a8Kl!"
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
      account.custom_data.put(:rank, "Captain")
      expect(account.custom_data.get(:rank)).to eq("Captain")
      account.custom_data.save
      expect(reloaded_account.custom_data.get(:rank)).to eq("Captain")
    end

    it 'set nested custom data' do
      account.custom_data.put(:special_rank, "Captain")
      account.custom_data.put(:permissions, {"crew_quarters" => "93-601"})
      expect(account.custom_data.get(:permissions)).to eq({"crew_quarters" => "93-601"})
      account.custom_data.save
      expect(reloaded_account.custom_data.get(:special_rank)).to eq("Captain")
      expect(reloaded_account.custom_data.get(:permissions)).to eq({"crew_quarters" => "93-601"})
    end

    it 'not raise errors when saving a empty properties array' do
      account.custom_data.save
    end

    it 'trigger custom data saving on account.save' do
      account.custom_data.put(:rank, "Captain")
      account.surname = "Picard!"
      account.save
      expect(reloaded_account.surname).to eq("Picard!")
      expect(reloaded_account.custom_data.get(:rank)).to eq("Captain")
    end

    it 'delete all custom data' do
      account.custom_data.put(:rank, "Captain")
      account.custom_data.save
      expect(account.custom_data.get(:rank)).to eq("Captain")
      account.custom_data.delete
      expect(reloaded_account.custom_data.get(:rank)).to eq(nil)
    end

    it 'delete a specific custom data field' do
      account.custom_data.put(:rank, "Captain")
      account.custom_data.put("favorite_drink", "Earl Grey Tea")
      account.custom_data.save
      
      account.custom_data.delete(:rank)
      expect(reloaded_account.custom_data.get(:rank)).to eq(nil)
      expect(reloaded_account.custom_data.get("favorite_drink")).to eq("Earl Grey Tea")
    end
  end

  describe "#for groups" do
    let(:directory) { test_api_client.directories.create name: 'test_directory' }

    let(:group) { directory.groups.create name: 'test_group' }

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
      group.custom_data.put(:series, "Enterprise")
      expect(group.custom_data.get(:series)).to eq("Enterprise")
      group.custom_data.save
      expect(reloaded_group.custom_data.get(:series)).to eq("Enterprise")
    end

    it 'set nested custom data' do
      group.custom_data.put(:special_rank, "Captain")
      group.custom_data.put(:permissions, {"crew_quarters" => "93-601"})
      expect(group.custom_data.get(:permissions)).to eq({"crew_quarters" => "93-601"})
      group.custom_data.save
      expect(reloaded_group.custom_data.get(:special_rank)).to eq("Captain")
      expect(reloaded_group.custom_data.get(:permissions)).to eq({"crew_quarters" => "93-601"})
    end

    it 'not raise errors when saving a empty properties array' do
      group.custom_data.save
    end

    it 'trigger custom data saving on group.save' do
      group.custom_data.put(:series, "Enterprise")
      group.description = "founded on the twin principles of joy and service"
      group.save
      expect(reloaded_group.description).to eq("founded on the twin principles of joy and service")
      expect(reloaded_group.custom_data.get(:series)).to eq("Enterprise")
    end

    it 'delete all custom data' do
      group.custom_data.put("series", "Enterprise")
      group.custom_data.save
      expect(group.custom_data.get("series")).to eq("Enterprise")
      group.custom_data.delete
      expect(reloaded_group.custom_data.get("series")).to eq(nil)
    end

    it 'delete a specific custom data field' do
      group.custom_data.put("series", "Enterprise")
      group.custom_data.put("favorite_drink", "Earl Grey Tea")
      group.custom_data.save
      
      group.custom_data.delete("series")
      expect(reloaded_group.custom_data.get("series")).to eq(nil)
      expect(reloaded_group.custom_data.get("favorite_drink")).to eq("Earl Grey Tea")
    end
  end

end
