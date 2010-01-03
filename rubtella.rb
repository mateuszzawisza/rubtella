require 'config/config'
require 'lib/errors'
require 'lib/peer'
require 'lib/tcp_data'
require 'lib/http_data'
require 'lib/rubtella'



gnutella = Rubtella::Sender.new Rubtella::Peer.new("82.131.108.231",27363) 
gnutella.connect
