module Stormpath
  module IdSite
    class IdSiteResult
      attr_accessor :jwt_response, :account_href, :state, :status, :is_new_account

      alias_method :new_account?, :is_new_account

      def initialize(jwt_response)
        @jwt_response = jwt_response
        @account_href = jwt_response["sub"]
        @status = jwt_response["status"]
        @state = jwt_response["state"]
        @is_new_account = jwt_response["isNewSub"]
      end

      def jwt_invalid?(api_key_id)
        @jwt_response['aud'] != api_key_id
      end
    end
  end
end

