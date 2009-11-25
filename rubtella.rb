require 'lib/peer'
require 'lib/tcp_data'
require 'lib/rubtella'

gnutella = Rubtella::Sender.new Rubtella::Peer.new("99.194.60.182",44577) 
gnutella.connect
