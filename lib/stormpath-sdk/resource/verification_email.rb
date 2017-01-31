module Stormpath
  module Resource
    class VerificationEmail < Stormpath::Resource::Instance
      prop_accessor :login, :account_store

      belongs_to :application
    end
  end
end
