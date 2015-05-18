module Stormpath
  class IdSiteResult
    attr_accessor :account_href, :state, :status, :is_new_account

    alias_method :is_new_account?, :is_new_account
    alias_method :new_account?, :is_new_account

    def initialize(jwt_response)
      @account_href = jwt_response["sub"]
      @status = jwt_response["status"]
      @state = jwt_response["state"]
      @is_new_account = jwt_response["isNewSub"]
    end
  end
end

