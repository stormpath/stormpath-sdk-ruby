module Stormpath

  module Authentication

    class UsernamePasswordRequest

      attr_reader :host

      def initialize username, password, host
        @username = username
        @password = (password != nil and password.length > 0) ? password.chars.to_a : "".chars.to_a
        @host = host
      end

      def get_principals
        @username
      end

      def get_credentials
        @password
      end

      ##
      # Clears out (nulls) the username, password, and host.  The password bytes are explicitly set to
      # <tt>0x00</tt> to eliminate the possibility of memory access at a later time.
      def clear
        @username = nil
        @host = nil

        @password.each { |char|

          char = 0x00
        }

        @password = nil
      end

    end

  end

end

