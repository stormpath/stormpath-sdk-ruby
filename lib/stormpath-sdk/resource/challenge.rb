module Stormpath
  module Resource
    class Challenge < Stormpath::Resource::Instance
      prop_accessor :message
      prop_reader :status, :created_at, :modified_at

      belongs_to :factor
      belongs_to :account

      def validate(code)
        Stormpath::Authentication::ChallengeValidator.new(data_store, href).validate(code)
      end
    end
  end
end
