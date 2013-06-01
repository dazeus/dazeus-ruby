module Dazeus
  module Event
    class Event < Hash
      attr_accessor :event, :params, :dazeus

      def initialize(data, dazeus)
        super()
        self.merge! data
        @dazeus = dazeus
        @event = self['event']
        @params = self['params']
        post_init
      end

      def post_init

      end
    end
  end
end
