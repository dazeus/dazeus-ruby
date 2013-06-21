require 'dazeus/event/action'
require 'dazeus/event/alias'
require 'dazeus/event/command'
require 'dazeus/event/event'
require 'dazeus/event/message'
require 'dazeus/event/names'
require 'dazeus/event/whois'


module Dazeus
  class Dazeus
    attr_accessor :conn
    attr_reader :handshake

    Protocol = 1

    def initialize(connection)
      @conn = connection
      @subscribers = {}
      @handshake = false
    end

    def networks
      response = send_receive({:get => 'networks'})
      return [] unless response['success']
      response['networks']
    end

    def channels(network)
      response = send_receive({:get => 'channels', :params => [network]})
      return [] unless response['success']
      response['channels']
    end

    def message(network, channel, message)
      response = send_receive({:do => 'message', :params => [network, channel, message]})
      response['success']
    end

    def action(network, channel, message)
      response = send_receive({:do => 'action', :params => [network, channel, message]})
      response['success']
    end

    def reply(network, channel, nick, message, highlight=true, action=false)
      bot_nick = self.nick(network)
      if channel == bot_nick
        if action
          self.action(network, nick, message)
        else
          self.message(network, nick, message)
        end
      else
        message = nick + ': ' + message if highlight
        if action
          self.action(network, channel, message)
        else
          self.message(network, channel, message)
        end
      end
    end

    def send_names(network, channel)
      response = send_receive({:do => 'names', :params => [network, channel]})
      response['success']
    end

    def names(network, channel, &block)
      fn = lambda do |response|
        unsubscribe('NAMES', &fn)
        block.call(response)
      end
      subscribe('NAMES', &fn)
      send_names(network, channel)
    end

    def names_sync(network, channel)
      resolved = false
      result = nil
      names(network, channel) do |names|
        resolved = true
        result = names
      end

      # Wait for the names request to be resolved
      loop do
        break if resolved
        once
      end
      result
    end

    def send_whois(network, nick)
      response = send_receive({:do => 'whois', :params => [network, nick]})
      response['success']
    end

    def whois(network, nick, &block)
      fn = lambda do |response|
        block.call(response)
        unsubscribe('WHOIS', &fn)
      end
      subscribe('WHOIS', &fn)
      send_whois(network, nick)
    end

    def whois_sync(network, nick)
      resolved = false
      result = nil
      whois(network, nick) do |whois|
        resolved = true
        result = whois
      end

      # Wait for the whois request to be resolved
      loop do
        break if resolved
        once
      end
      result
    end

    def join(network, channel)
      response = send_receive({:do => 'join', :params => [network, channel]})
      response['success']
    end

    def part(network, channel)
      response = send_receive({:do => 'part', :params => [network, channel]})
      response['success']
    end

    def nick(network)
      response = send_receive({:get => 'nick', :params => [network]})
      return nil unless response['success']
      response['nick']
    end

    def do_handshake(name, version, config=nil)
      config = name if config == nil
      response = send_receive({:do => 'handshake', :params => [name, version, Protocol, config]})
      @handshake = true if response['success']
      response['success']
    end

    def get_config(name, group=:plugin)
      return nil unless group == :core || @handshake
      response = send_receive({:get => 'config', :params => [group.to_s, name]})
      return nil unless response['success'] && response.key?('value')
      response['value']
    end

    def highlight_character
      get_config('highlight', :core)
    end

    def get_property(name, scope=[])
      data = {:do => 'property', :params => ['get', name]}
      data[:scope] = scope if scope.length > 0
      response = send_receive(data)
      return nil unless response['success'] && response.key?('value')
      response['value']
    end

    def set_property(name, value, scope=[])
      data = {:do => 'property', :params => ['set', name, value]}
      data[:scope] = scope if scope.length > 0
      response = send_receive(data)
      response['success']
    end

    def unset_property(name, scope=[])
      data = {:do => 'property', :params => ['unset', name]}
      data[:scope] = scope if scope.length > 0
      response = send_receive(data)
      response['success']
    end

    def get_property_keys(name, scope=[])
      data = {:do => 'property', :params => ['keys', name]}
      data[:scope] = scope if scope.length > 0
      response = send_receive(data)
      return [] unless response['success'] && response.key?('keys')
      response['keys']
    end

    def subscribe(event, &callback)
      success = true
      event.upcase.split(' ').each do |ev|
        ev = Event::Alias.resolve(ev)
        @subscribers[ev] = [] unless @subscribers.has_key?(ev)
        if @subscribers[ev].length == 0
          response = send_receive({:do => 'subscribe', :params => [ev]})
          success = success && response['success']
        end
        @subscribers[ev].push callback
      end
      success
    end

    def unsubscribe(event, &callback)
      success = true
      event.upcase.split(' ').each do |ev|
        ev = Event::Alias.resolve(ev)
        @subscribers[ev] = [] unless @subscribers.has_key?(ev)
        precount = @subscribers[ev].length
        @subscribers[ev].delete callback
        if precount > 0 && @subscribers[ev].length == 0
          response = send_receive({:do => 'unsubscribe', :params => [ev]})
          success = success && response['success']
        end
      end
      success
    end

    def on_command(command, network=nil, &callback)
      @subscribers['COMMAND'] = [] unless @subscribers.has_key?('COMMAND')
      @subscribers['COMMAND'][command] = [] unless @subscribers['COMMAND'].has_key?(command)
      success = true
      if @subscribers['COMMAND'][command].length == 0
        response = send_receive({:do => 'command', :params => [command]})
        success = response['success']
      end
      @subscribers['COMMAND'][command].push [network, callback]
      success
    end

    def once
      handle_event conn.receive
    end

    def run
      loop do
        break if conn.closed?
        once
      end
    end
    alias_method :start, :run

    def close
      conn.close
    end
    alias_method :stop, :close


    private
      def send_receive(message)
        conn.send message
        response = nil
        loop do
          break if conn.closed?
          response = conn.receive
          break unless handle_event response
        end

        return {} if response == nil
        response
      end

      def handle_event(response)
        if response.has_key?('event')
          event = response['event'].upcase
          obj = case event
            when 'PRIVMSG', 'PRIVMSG_ME' then Event::Message.new(response, self)
            when 'COMMAND' then Event::Command.new(response, self)
            when 'ACTION', 'ACTION_ME' then Event::Action.new(response, self)
            when 'NAMES' then Event::Names.new(response, self)
            when 'WHOIS' then Event::Whois.new(response, self)
            else Event::Event.new(response, self)
          end

          if event == 'COMMAND'
            @subscribers[event][obj['params'][3]].each do |callback|
              callback.call(obj)
            end
          else
            @subscribers[event].each do |callback|
              callback.call(obj)
            end
          end
          true
        else
          false
        end
      end
  end
end
