module Dazeus
  module Event
    module Alias
      @@aliases = {
        'MESSAGE' => 'PRIVMSG',
        'MESSAGE_ME' => 'PRIVMSG_ME',
        'RENAME' => 'NICK',
        'CTCPREP' => 'CTCP_REP',
        'MESSAGEME' => 'PRIVMSG_ME',
        'PRIVMSGME' => 'PRIVMSG_ME',
        'ACTIONME' => 'ACTION_ME',
        'CTCPME' => 'CTCP_ME'
      }

      def self.resolve(a)
        return a unless @@aliases.has_key?(a)
        @@aliases[a]
      end

      def self.add_alias(from, to)
        @@aliases[from] = to
      end
    end
  end
end
