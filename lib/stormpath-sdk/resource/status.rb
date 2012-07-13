module Stormpath

  module Resource

    module Status

      ENABLED = 'ENABLED'
      DISABLED = 'DISABLED'

      def get_status_hash
        {ENABLED => ENABLED, DISABLED => DISABLED}
      end

    end

  end

end

