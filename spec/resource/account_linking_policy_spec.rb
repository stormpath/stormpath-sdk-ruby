require 'spec_helper'

describe Stormpath::Resource::AccountLinkingPolicy, :vcr do
  describe 'instances should respond to attribute property methods' do
    let!(:application) { test_api_client.applications.create(application_attrs) }
    let(:account_linking_policy) { application.account_linking_policy }

    it do
      expect(account_linking_policy).to be_a Stormpath::Resource::AccountLinkingPolicy

      [:status, :automatic_provisioning, :matching_property].each do |property_accessor|
        expect(account_linking_policy).to respond_to(property_accessor)
        expect(account_linking_policy).to respond_to("#{property_accessor}=")
        if property_accessor == :matching_property
          expect(account_linking_policy.send(property_accessor)).to be_nil
        else
          expect(account_linking_policy.send(property_accessor)).to be_a String
        end
      end

      [:created_at, :modified_at].each do |property_getter|
        expect(account_linking_policy).to respond_to(property_getter)
        expect(account_linking_policy.send(property_getter)).to be_a String
      end

      expect(account_linking_policy.tenant).to be_a Stormpath::Resource::Tenant
    end
  end
end
