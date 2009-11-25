require 'socket'  

streamSock = TCPSocket.new "127.0.0.1", 6789
streamSock.puts "GNUTELLA/0.6 200 OK\nUser-Agent: Rubytella\nPong-Caching: 0.1\nGGEP: 0.5\nPrivate-Data: 5ef89a"

str = streamSock.recv 1000
puts str  
streamSock.puts "GNUTELLA/0.6 200 OK\nUser-Agent: Rubytella\nPong-Caching: 0.1\nGGEP: 0.5\nPrivate-Data: 5ef89a"
streamSock.close 

