class Stormpath::Resource::CustomData < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  belongs_to :account
  
end
