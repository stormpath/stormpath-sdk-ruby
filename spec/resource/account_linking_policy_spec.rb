require 'spec_helper'

describe Stormpath::Resource::AccountLinkingPolicy, :vcr do
  describe 'instances should respond to attribute property methods' do
    let!(:application) { test_api_client.applications.create(application_attrs) }
    let(:account_linking_policy) { application.account_linking_policy }

    after { application.delete }

    it do
      expect(account_linking_policy).to be_a Stormpath::Resource::AccountLinkingPolicy

      [:status, :automatic_provisioning].each do |property_accessor|
        expect(account_linking_policy).to respond_to(property_accessor)
        expect(account_linking_policy).to respond_to("#{property_accessor}=")
        expect(account_linking_policy.send(property_accessor)).to be_a String
      end

      expect(account_linking_policy).to respond_to(:matching_property)
      expect(account_linking_policy).to respond_to('matching_property=')
      expect(account_linking_policy.send(:matching_property)).to be_nil

      [:created_at, :modified_at].each do |property_getter|
        expect(account_linking_policy).to respond_to(property_getter)
        expect(account_linking_policy.send(property_getter)).to be_a String
      end

      expect(account_linking_policy.tenant).to be_a Stormpath::Resource::Tenant
    end
  end
end
