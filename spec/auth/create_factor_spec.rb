require 'spec_helper'

describe 'CreateFactor', vcr: true do
  let(:client) { test_api_client }
  let(:directory) { client.directories.create name: random_directory_name }
  let(:account) do
    directory.accounts.create(email: 'test@example.com',
                              given_name: 'Ruby SDK',
                              password: 'P@$$w0rd',
                              surname: 'SDK',
                              username: 'rubysdk')
  end

  context 'with valid attributes' do
    context 'with challenge' do
      let(:factor) do
        Stormpath::Authentication::CreateFactor.new(client,
                                                    account,
                                                    'SMS',
                                                    phone: { number: '+385958142457',
                                                             name: 'Rspec test phone',
                                                             description: 'This is a testing phone number' },
                                                    challenge: { message: 'Enter code please: ' })
      end

      it 'should create factor' do
        factor.save
      end

      it 'should create challenge' do
        factor.save
        expect(factor.challenges.count).to be 1
      end
    end

    context 'without challenge' do
      let(:factor) do
        Stormpath::Authentication::CreateFactor.new(client,
                                                    account,
                                                    'SMS',
                                                    phone: { number: '+385958142457',
                                                             name: 'Rspec test phone',
                                                             description: 'This is a testing phone number' })
      end

      it 'should create factor' do
        factor.save # TODO: currently it returns a hash of the created resource 'factor' => we need to convert it into a Factor resource
      end

      it 'should not create challenge' do
        factor.save
        expect(factor.challenges.count).to be 0
      end
    end


  end

  after do
    account.delete if account
    directory.delete if directory
  end
end
