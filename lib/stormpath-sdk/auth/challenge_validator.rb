module Stormpath
  module Authentication
    class ChallengeValidator
      attr_reader :data_store, :href

      def initialize(data_store, href)
        @data_store = data_store
        @href = href
      end

      def validate(code)
        attempt.code = code
        data_store.create(href, attempt, Stormpath::Resource::Challenge)
      end

      private

      def attempt
        @attempt ||= data_store.instantiate(Stormpath::Authentication::ChallengeFactorAttempt, nil)
      end
    end
  end
end
