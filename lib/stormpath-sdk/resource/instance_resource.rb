module Stormpath

  module Resource

    class InstanceResource < Resource

      def save
        dataStore.save self
      end
    end
  end

end
