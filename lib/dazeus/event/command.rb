require 'dazeus/event/message'

module Dazeus
  module Event
    class Command < Message
      attr_accessor :command, :args, :remainder
      def post_init
        super
        @remainder = if @params.length > 4 then @params[4] else '' end
        @message = @dazeus.highlightCharacter + @message
        @message += ' ' + @remainder if @remainder.length > 0
        @args = @params[5..-1]
        @args = [] if @args == nil
      end
    end
  end
end
