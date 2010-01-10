require 'rubtella'


Thread.new do
  server = Rubtella::Listener.new
  server.listen
end

Thread.new do
  gnutella = Rubtella::Sender.new Rubtella::Peer.new("70.188.16.73",38093) 
  gnutella.connect
  gnutella.send_query("doors")
end

while true
  sleep 100
end
