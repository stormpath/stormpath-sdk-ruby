 # test_api_client.accounts.get "https://api.stormpath.com/v1/accounts/1SmmWv659tY9Eeb4qKZqr0"
require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do

  RESERVED_FIELDS = %w( created_at modified_at meta sp_meta spmeta ion_meta ionmeta )

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

    let(:reloaded_account_2) { test_api_client.accounts.get account.href }

    after do
      account.delete if account
      directory.delete if directory
    end
    
    it 'read reserved data' do
      expect(account.custom_data["href"]).not_to eq(nil)
      expect(account.custom_data["created_at"]).not_to eq(nil)
      expect(account.custom_data["modified_at"]).not_to eq(nil)
    end

    RESERVED_FIELDS.each do |reserved_field|
      it "set reserved data #{reserved_field} should raise error" do
        account.custom_data[reserved_field] = 12
        expect{ account.custom_data.save }.to raise_error
      end
    end

    it 'set custom data' do
      account.custom_data[:rank] = "Captain"
      expect(account.custom_data[:rank]).to eq("Captain")
      account.custom_data.save
      expect(reloaded_account.custom_data[:rank]).to eq("Captain")
    end

    it 'set nested custom data' do
      account.custom_data[:special_rank] = "Captain"
      account.custom_data[:permissions] = {"crew_quarters" => "93-601"}
      expect(account.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
      account.custom_data.save
      expect(reloaded_account.custom_data[:special_rank]).to eq("Captain")
      expect(reloaded_account.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
    end

    it 'not raise errors when saving a empty properties array' do
      account.custom_data.save
    end

    it 'trigger custom data saving on account.save' do
      account.custom_data[:rank] = "Captain"
      account.surname = "Picard!"
      account.save
      expect(reloaded_account.surname).to eq("Picard!")
      expect(reloaded_account.custom_data[:rank]).to eq("Captain")
    end

    it 'trigger custom data saving on account.save with complex custom data' do
      account.custom_data[:permissions] = {"crew_quarters" => "93-601"}
      account.surname = "Picard!"
      account.save
      expect(reloaded_account.surname).to eq("Picard!")
      expect(reloaded_account.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
    end

    it 'update custom data through account.save, cache should be cleared' do
      account.custom_data[:permissions] = {"crew_quarters" => "93-601"}
      account.custom_data.save

      expect(reloaded_account.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})

      reloaded_account.custom_data[:permissions] = {"crew_quarters" => "601-93"}

      reloaded_account.save
      expect(reloaded_account_2.custom_data[:permissions]).to eq({"crew_quarters" => "601-93"})
    end

    it 'delete all custom data' do
      account.custom_data[:rank] = "Captain"
      account.custom_data.save
      expect(account.custom_data[:rank]).to eq("Captain")
      account.custom_data.delete
      expect(reloaded_account.custom_data[:rank]).to eq(nil)
    end

    it 'delete a specific custom data field' do
      account.custom_data[:rank] = "Captain"
      account.custom_data["favorite_drink"] = "Earl Grey Tea"
      account.custom_data.save
      
      account.custom_data.delete(:rank)
      account.custom_data.save

      expect(reloaded_account.custom_data[:rank]).to eq(nil)
      expect(reloaded_account.custom_data["favorite_drink"]).to eq("Earl Grey Tea")
    end

    context 'should respond to' do
      it '#has_key?' do
        expect(account.custom_data.has_key? "created_at").to be_true
      end

      it '#include?' do
        expect(account.custom_data.include? "created_at").to be_true
      end

      it '#has_value?' do
        account.custom_data[:rank] = "Captain"
        account.custom_data.save
        expect(reloaded_account.custom_data.has_value? "Captain").to be_true
      end

      it '#store' do
        account.custom_data.store(:rank, "Captain")
        account.custom_data.save
        expect(reloaded_account.custom_data[:rank]).to eq("Captain")
      end

      it '#keys' do
        expect(account.custom_data.keys).to be_kind_of(Array)
        expect(account.custom_data.keys).to have_at_least(3).items
        expect(account.custom_data.keys.map {|key| key.to_s.camelize :lower}).to eq(account.custom_data.properties.keys)
      end

      it '#values' do
        account.custom_data[:permissions] = {"crew_quarters" => "93-601"}
        account.custom_data.save
        expect(reloaded_account.custom_data.values).to include({"crew_quarters" => "93-601"})
        expect(reloaded_account.custom_data.values).to eq(reloaded_account.custom_data.properties.values)
      end
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
      expect(group.custom_data["href"]).not_to eq(nil)
      expect(group.custom_data["created_at"]).not_to eq(nil)
      expect(group.custom_data["modified_at"]).not_to eq(nil)
    end

    RESERVED_FIELDS.each do |reserved_field|
      it "set reserved data #{reserved_field} should raise error" do
        group.custom_data[reserved_field] = 12
        expect{ group.custom_data.save }.to raise_error
      end
    end

    it 'set custom data' do
      group.custom_data[:series] = "Enterprise"
      expect(group.custom_data[:series]).to eq("Enterprise")
      group.custom_data.save
      expect(reloaded_group.custom_data[:series]).to eq("Enterprise")
    end

    it 'set nested custom data' do
      group.custom_data[:special_rank] = "Captain"
      group.custom_data[:permissions] = {"crew_quarters" => "93-601"}
      expect(group.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
      group.custom_data.save
      expect(reloaded_group.custom_data[:special_rank]).to eq("Captain")
      expect(reloaded_group.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
    end

    it 'not raise errors when saving a empty properties array' do
      group.custom_data.save
    end

    it 'trigger custom data saving on group.save' do
      group.custom_data[:series] = "Enterprise"
      group.description = "founded on the twin principles of joy and service"
      group.save
      expect(reloaded_group.description).to eq("founded on the twin principles of joy and service")
      expect(reloaded_group.custom_data[:series]).to eq("Enterprise")
    end

    it 'delete all custom data' do
      group.custom_data["series"] = "Enterprise"
      group.custom_data.save
      expect(group.custom_data["series"]).to eq("Enterprise")
      group.custom_data.delete
      expect(reloaded_group.custom_data["series"]).to eq(nil)
    end

    it 'delete a specific custom data field' do
      group.custom_data["series"] = "Enterprise"
      group.custom_data["favorite_drink"] = "Earl Grey Tea"
      group.custom_data.save
      
      group.custom_data.delete("series")
      group.custom_data.save

      expect(reloaded_group.custom_data["series"]).to eq(nil)
      expect(reloaded_group.custom_data["favorite_drink"]).to eq("Earl Grey Tea")
    end
  end

end
