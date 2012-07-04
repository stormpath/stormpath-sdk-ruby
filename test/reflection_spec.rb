require "stormpath-sdk"

include Stormpath::Resource

describe 'Reflection test' do

  it Tenant do

    tenant = create_object Tenant, 'dataStore', 'properties'

    tenant.should be_instance_of Tenant
  end
end

def create_object(clazz, dataStore, properties)

  clazz.new dataStore, properties

end