require 'dazeus/version'
require 'dazeus/dazeus'
require 'dazeus/connection'

module Dazeus
  def self.create(address)
    Dazeus.new(Connection.new(address))
  end
end
