#!/usr/bin/ruby  
# ruby gnutella client

require 'socket'  


PORT = 6789

module Rubtella
  class Listener

    #listen for connection
    def listen
      server = TCPServer.new(PORT)  
        
      while (session = server.accept) 

        
         Thread.start do  

           begin
             parse_request session
           rescue => e
             session.puts "Rubtella Server Error: " + e.to_s
           ensure
             session.close
           end

         end
      end   #end loop 

    end

    def parse_request request
      puts request.recv 100
      request.puts( "Hello back\n" )  
    end

  end

  class Sender

    def send
      stream = TCPSocket.new "127.0.0.1", 6789 
      stream.puts "Hello\n"
      response = stream.recv 100 
      puts str  
      stream.close 
    end
  end
end
   
gnutella = Rubtella::Listener.new
gnutella.listen
