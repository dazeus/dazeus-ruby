require 'dazeus/event/event'

module Dazeus
  module Event
    class Names < Event
      attr_accessor :names, :network, :server, :channel

      def post_init
        super
        @network = @params[0]
        @server = @params[1]
        @channel = @params[2]
        @names = @params[3..-1]
      end
    end
  end
end
