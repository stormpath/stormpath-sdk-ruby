require 'spec_helper'

describe Stormpath::Resource::Tenant, :vcr do

  describe "instances should respond to attribute property methods" do
    let(:tenant) { test_api_client.tenant }

    it do
      expect(tenant).to be_a Stormpath::Resource::Tenant

      [:name, :key].each do |property_accessor|
        expect(tenant).to respond_to(property_accessor)
        expect(tenant.send property_accessor).to be_a String
      end

      expect(tenant.applications).to be_a Stormpath::Resource::Collection
      expect(tenant.directories).to be_a Stormpath::Resource::Collection
    end
  end

end