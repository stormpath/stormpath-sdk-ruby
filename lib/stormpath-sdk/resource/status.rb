module Stormpath

  module Resource

    module Status

      :ENABLED
      :DISABLED
      status_hash = {:ENABLED => :ENABLED.to_s, :DISABLED => :DISABLED.to_s}

      def get_status_hash
        status_hash
      end

    end

  end

end

