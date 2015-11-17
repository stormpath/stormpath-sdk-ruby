module Stormpath
  module IdSite
    class Error < Stormpath::Error
      attr_accessor :status, :code, :message, :developer_message, :more_info

      def initialize(type)
        @status  = errors[type][:status]
        @code    = errors[type][:code]
        @message = errors[type][:message]
        @developer_message = errors[type][:developer_message]
        super(self)
      end

      private

      def errors
        {
          jwt_cb_uri_incorrect: {
            status: 400,
            code: 400,
            message: "The specified callback URI (cb_uri) is not valid",
            developer_message: "The specified callback URI (cb_uri) is not valid. Make "\
              "sure the callback URI specified in your ID Site configuration matches the value specified."
          },
          jwt_expired: {
            status: 400,
            code: 10011,
            message: "Token is invalid",
            developer_message: "Token is no longer valid because it has expired"
          }, 
          jwt_invalid: {
            status: 400,
            code: 10012,
            message: "Token is invalid",
            developer_message: "Token is invalid because the issued at time (iat) is after the current time"
          }
        }
      end
    end
  end
end

