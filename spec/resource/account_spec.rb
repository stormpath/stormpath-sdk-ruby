require 'spec_helper'

describe Stormpath::Account do
  describe '#save' do
    context 'when property values have changed' do
      let(:account_uri) { '/accounts/3Osia7j72CU2j5I5UwJUjj' }
      let(:new_surname) do
        "NewSurname#{SecureRandom.uuid}"
      end
      let(:reloaded_account) { Stormpath::Account.get test_api_client, account_uri }

      before do
        account = Stormpath::Account.get test_api_client, account_uri
        account.surname = new_surname
        account.save
      end

      it 'saves changes to the account' do
        reloaded_account.surname.should == new_surname
      end
    end
  end
end
