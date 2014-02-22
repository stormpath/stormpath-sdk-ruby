require 'spec_helper'

describe Stormpath::Resource::Tenant, :vcr do

  describe "instances should respond to attribute property methods" do
    subject(:tenant) { test_api_client.tenant }

    it { should be_instance_of Stormpath::Resource::Tenant }

    [:name, :key].each do |property_accessor|
      it { should respond_to property_accessor }
      its(property_accessor) { should be_instance_of String }
    end

    its(:applications) { should be_instance_of Stormpath::Resource::Collection }
    its(:directories) { should be_instance_of Stormpath::Resource::Collection }
  end

end