module Stormpath

  module Authentication

    class BasicLoginAttempt < Stormpath::Resource::Resource

      TYPE = "type"
      VALUE = "value"

      def get_type
        get_property TYPE
      end

      def set_type type
        set_property TYPE, type
      end

      def get_value
        get_property VALUE
      end

      def set_value value
        set_property VALUE, value
      end

    end

  end

end