module Stormpath

  module Resource

    class InstanceResource < Resource

      def save
        data_store.save self
      end
    end
  end

end
