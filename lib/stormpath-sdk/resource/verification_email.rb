class Stormpath::Resource::VerificationEmail < Stormpath::Resource::Instance
  prop_accessor :login, :account_store

  belongs_to :application
end
