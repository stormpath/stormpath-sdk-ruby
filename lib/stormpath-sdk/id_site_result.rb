module Stormpath
  class IdSiteResult
    attr_accessor :account, :state, :status

    def initialize(jwt_response)
      @account = jwt_response["sub"]
      @status = jwt_response["status"]
      @state = jwt_response["state"]
      @is_new_account = jwt_response["isNewSub"]
    end

    def new_account?
      @is_new_account
    end
  end
end

