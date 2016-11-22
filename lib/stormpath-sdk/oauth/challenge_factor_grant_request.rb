module Stormpath
  module Oauth
    class ChallengeFactorGrantRequest
      attr_reader :challenge, :code

      def initialize(challenge, code)
        @challenge = challenge
        @code = code
      end

      def grant_type
        'stormpath_factor_challenge'
      end
    end
  end
end
