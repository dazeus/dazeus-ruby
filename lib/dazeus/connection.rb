require 'socket'
require 'json'

module Dazeus
  class Connection
    def initialize(address)
      @socket = create_socket(address)
      @cache = []
    end

    def send(message)
      @socket.sendmsg(dazeusify message)
    end

    def receive
      if @cache.length == 0
        message = @socket.recvmsg[0]
        message = message.force_encoding 'UTF-8'
        message = message.strip

        while message.length > 0
          digits = ""
          while message[0] =~ /\d/
            digits += message.slice! 0
          end
          @cache.push JSON.parse(message.slice!(0, digits.to_i))
          message = message.strip
        end
      end
      @cache.shift
    end

    def dazeusify(message)
      msg = JSON.dump(message)
      msg.bytesize.to_s + msg
    end

    private
      def create_socket(address)
        if address.start_with? 'tcp://'
          address = address[6..-1]
          if address.count ':' != 1
            raise 'Invalid TCP socket format, specify both host and port'
          end
          host, port = address.split ':'
          TCPSocket.new host, port
        elsif address.start_with? 'unix://'
          UNIXSocket.new address[7..-1]
        else
          raise 'Invalid socket format'
        end
      end
  end
end
