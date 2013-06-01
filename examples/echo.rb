#!/usr/bin/env ruby
require "dazeus"

client = Dazeus::create('unix:///tmp/dazeus.sock')
client.subscribe('message') {|msg| msg.reply(msg.message) }
client.run
