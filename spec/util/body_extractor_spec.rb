require 'spec_helper'

describe Stormpath::Util::BodyExtractor do
  let(:body) { Stormpath::Util::BodyExtractor.for(resource).call }

  describe 'resource' do
    context 'is nil' do
      let(:resource) { nil }

      it 'should return nil' do
        expect(body).to be_nil
      end
    end

    context 'is form data' do
      let(:resource) { Stormpath::Oauth::PasswordGrant.new('') }
      let(:grant_type) { 'password' }
      let(:username) { 'stormpath' }
      let(:password) { '1234567' }
      let(:mocked_form_properties) do
        {
          grant_type: grant_type,
          username: username,
          password: password
        }
      end
      before do
        allow_any_instance_of(Stormpath::Oauth::PasswordGrant).to receive(:form_properties)
          .and_return(mocked_form_properties)
      end

      it 'should return ' do
        expect(body).to eq "grant_type=#{grant_type}&username=#{username}&password=#{password}"
      end
    end

    context 'is hash data' do
      context 'default' do
        xit 'should be simplified'
      end
      context 'custom data' do
        xit 'should not be simplified'
      end
      context 'items' do
        xit 'should not be simplified'

        xit 'should be camel cased'
      end
      context 'phone' do
        xit 'should not be simplified'
      end
      context 'config' do
        xit 'should not be simplified'
      end
      context 'provider' do
        xit 'should not be simplified'
      end
      context 'providerData' do
        xit 'should not be simplified'
      end
      context 'accountStore' do
        xit 'should not be simplified'
        xit 'should be camel cased'
      end
      context 'mapping rules' do
        xit 'should not be simplified'
        xit 'should be camel cased'
      end
      context 'agent config' do
        xit 'should not be simplified'
        xit 'should be camel cased'
      end
      context 'application web config' do
        xit 'should not be simplified'
        xit 'should be camel cased'
      end
    end
  end
end
