module Stormpath
  module Oauth
    class Error < Stormpath::Error
      attr_accessor :status, :code, :message, :developer_message, :more_info, :request_id

      def initialize(type)
        @status  = errors[type][:status]
        @code    = errors[type][:code]
        @message = errors[type][:message]
        @developer_message = errors[type][:developer_message]
        @request_id = errors[type][:request_id]
        super(self)
      end

      private

      def errors
        {
          jwt_cb_uri_incorrect: {
            status: 400,
            code: 400,
            message: 'The specified callback URI (cb_uri) is not valid',
            developer_message: 'The specified callback URI (cb_uri) is not valid. Make '\
              'sure the callback URI specified in your ID Site configuration matches the value specified.',
            request_id: 'Oauth error UUID'
          },
          jwt_expired: {
            status: 400,
            code: 10011,
            message: 'Token is invalid',
            developer_message: 'Token is no longer valid because it has expired',
            request_id: 'Oauth error UUID'
          },
          jwt_invalid: {
            status: 400,
            code: 10012,
            message: 'Token is invalid',
            developer_message: 'Token is invalid because the issued at time (iat) is after the current time',
            request_id: 'Oauth error UUID'
          },
          jwt_invalid_issuer: {
            status: 400,
            code: 10014,
            message: 'Token is invalid',
            developer_message: 'Token is invalid because the issuer of the token does not match the Application validating the token.',
            request_id: 'Oauth error UUID'
          },
          jwt_invalid_signature: {
            status: 400,
            code: 10017,
            message: 'Token is invalid',
            developer_message: 'Token is invalid because verifying the signature of a JWT failed.',
            request_id: 'Oauth error UUID'
          },
          jwt_invalid_stt: {
            status: 400,
            code: nil,
            message: 'Token is invalid',
            developer_message: "Token is invalid because the stt header doesn't match the right type",
            request_id: 'Oauth error UUID'
          }
        }
      end
    end
  end
end
