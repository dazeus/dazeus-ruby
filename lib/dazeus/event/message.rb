require 'dazeus/event/event'

module Dazeus
  module Event
    class Message < Event
      attr_accessor :message, :network, :channel, :nick

      def post_init
        super
        @network = @params[0]
        @nick = @params[1]
        @channel = @params[2]
        @message = @params[3]
      end

      def reply(message, highlight=false, action=false)
        @dazeus.reply(@network, @channel, @nick, message, highlight, action)
      end

      def highlight(message)
        reply(message, true)
      end

      def action(message)
        reply(message, false, true)
      end
    end
  end
end
