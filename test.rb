require 'socket'  

streamSock = TCPSocket.new "127.0.0.1", 6789 
streamSock.puts "Hello\n"
str = streamSock.recv 100 
puts str  
streamSock.close 

