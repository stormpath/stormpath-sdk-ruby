module Stormpath
  module Oauth
    class ChallengeFactorGrant < Stormpath::Resource::Base
      prop_accessor :grant_type, :challenge, :code

      def form_properties
        {
          grant_type: grant_type,
          challenge: challenge,
          code: code
        }
      end

      def set_options(request)
        set_property :grant_type, request.grant_type
        set_property :challenge, request.challenge
        set_property :code, request.code
      end

      def form_data?
        true
      end
    end
  end
end
