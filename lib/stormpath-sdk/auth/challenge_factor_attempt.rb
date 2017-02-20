module Stormpath
  module Authentication
    class ChallengeFactorAttempt < Stormpath::Resource::Base
      CODE = 'code'.freeze

      def code
        get_property CODE
      end

      def code=(code)
        set_property CODE, code
      end
    end
  end
end
