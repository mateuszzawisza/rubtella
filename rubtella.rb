require 'lib/errors'
require 'lib/peer'
require 'lib/tcp_data'
require 'lib/http_data'
require 'lib/rubtella'

gnutella = Rubtella::Sender.new Rubtella::Peer.new("76.103.181.29",27780) 
gnutella.connect
