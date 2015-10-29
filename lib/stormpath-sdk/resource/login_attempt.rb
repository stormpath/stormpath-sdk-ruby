class Stormpath::Resource::LoginAttempt < Stormpath::Resource::Instance
  prop_accessor :account

  belongs_to :application
end
