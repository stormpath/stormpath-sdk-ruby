module Stormpath

  module Resource

    module Utils

      def to_class_from_instance resource

        if resource.kind_of? Resource
          clazz = Kernel.const_get resource.class.name.split('::').last
        end
        clazz
      end
    end
  end
end