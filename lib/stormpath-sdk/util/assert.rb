module Stormpath

  module Util

    module Assert

      def assert_not_nil object, message

        raise ArgumentError, message, caller unless !object.nil?

      end

      def assert_kind_of clazz, object, message

        raise ArgumentError, message, caller unless object.kind_of? clazz

      end

      def assert_true arg, message

        raise ArgumentError, message, caller unless arg

      end
    end
  end
end