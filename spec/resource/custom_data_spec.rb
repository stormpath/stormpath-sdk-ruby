require 'spec_helper'

describe Stormpath::Resource::CustomData, :vcr do
  describe "should be able to" do
    
    let(:directory) { test_api_client.directories.create name: 'testDirectoryForCustomData' }

    let(:account) do
      directory.accounts.create email: 'jack.control@example.com',
        givenName: 'Jack',
        password: 'Passwort1',
        surname: 'Control',
        username: 'Jack Control'
    end

    let(:reloaded_account) { test_api_client.accounts.get account.href }

    let(:account_custom_data){ account.custom_data }

    after do
      account.delete if account
      directory.delete if directory
    end
    
    it 'read reserved data' do
      expect(account.custom_data.href).not_to eq(nil)
      expect(account.custom_data.created_at).not_to eq(nil)
      expect(account.custom_data.modified_at).not_to eq(nil)
    end

    it 'set custom data' do
      account_custom_data.band = "SHOS"
      account_custom_data.save
      expect(reloaded_account.custom_data.band).to eq("SHOS")
    end


  end

end
