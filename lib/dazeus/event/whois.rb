require 'dazeus/event/event'

module Dazeus
  module Event
    class Whois < Event
      attr_accessor :network, :server, :nick, :secure
      def post_init
        super
        @network = @params[0]
        @server = @params[1]
        @nick = @params[2]
        @secure = @params[3]
      end
    end
  end
end
