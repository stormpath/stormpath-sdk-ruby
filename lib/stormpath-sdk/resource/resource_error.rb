module Stormpath

  module Resource

    class ResourceError < RuntimeError

      def initialize error
        super !error.nil? ? error.get_message : ''
        @error = error
      end

      def get_status
        !@error.nil? ? @error.get_status : -1
      end

      def get_code
        !@error.nil? ? @error.get_code : -1
      end

      def get_developer_message
        !@error.nil? ? @error.get_developer_message : nil
      end

      def get_more_info
        !@error.nil? ? @error.get_more_info : nil
      end

    end

  end
end

