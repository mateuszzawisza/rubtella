require 'lib/errors'
require 'lib/peer'
require 'lib/tcp_data'
require 'lib/http_data'
require 'lib/rubtella'

gnutella = Rubtella::Sender.new Rubtella::Peer.new("98.151.179.184",4126) 
gnutella.connect
