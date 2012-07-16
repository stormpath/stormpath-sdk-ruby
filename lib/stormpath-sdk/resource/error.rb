module Stormpath

  module Resource

    class Error < Resource

      STATUS = "status"
      CODE = "code"
      MESSAGE = "message"
      DEV_MESSAGE = "developerMessage"
      MORE_INFO = "moreInfo"

      def initialize body
        super nil, body
      end

      def get_status
        get_property STATUS
      end

      def get_code
        get_property CODE
      end

      def get_message
        get_property MESSAGE
      end

      def get_developer_message
        get_property DEV_MESSAGE
      end

      def get_more_info
        get_property MORE_INFO
      end

    end

  end

end

