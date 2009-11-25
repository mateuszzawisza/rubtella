#!/usr/bin/ruby  
# ruby gnutella client

require 'socket'  


module Rubtella
  
  PORT = 6789

  GNUTELLA_REQUEST = "GNUTELLA CONNECT/0.6"
  GNUTELLA_RESPONSE_OK = "GNUTELLA/0.6 200 OK"
   

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
             puts "Rubtella Server Error: " + e.to_s
           ensure
             session.close
           end

         end
      end   #end loop 

    end

    def parse_request request
      req = request.recv 1000

      puts req
      request.send Sender.pong, 0
      puts 'response send!'
      req = request.recv 1000
      puts 'received content:'

      puts req
      puts 'received!'
    end

  end

  class Sender

    attr_accessor :peer
    
    def initialize peer
      @peer = peer
    end

    def send data
      stream = TCPSocket.new @peer.ip, @peer.port
      puts "sending request..."
      puts data
      stream.send data, 0
      response = stream.recv 1000
      puts "response:"
      puts response 
      stream.close 
    end

    def connect
      puts "connecting to: #{@peer.ip}:#{@peer.port}"
      stream = TCPSocket.new @peer.ip, @peer.port
      stream.send ping, 0
      response = stream.recv 1000
      puts "response:"
      resp = TCPData::Parser.new response 
      puts resp.status
      puts resp.peers.first.ip
      puts resp.peers.first.port
      stream.send pong, 0
      stream.close 

      if resp.ok?
        @connected = @peer
        puts "Connected with #{@connected.ip} #{@connected.port}"
      else
        @peer = resp.peers.first 
        connect
      end
    end

    def ping
     ping = TCPData::Builder.new
     ping.status = GNUTELLA_REQUEST
     ping.header["User-Agent"] = "Rubtella"
     ping.header["X-Ultrapeer"] = "False"
     ping.header["X-Query-Routing"] = "0.1"
     ping.build
    end

    def pong
      pong = TCPData::Builder.new
      pong.status = GNUTELLA_RESPONSE_OK
      pong.header["User-Agent"] = "Rubtella"
      pong.header["X-Ultrapeer"] = "False"
      pong.header["X-Query-Routing"] = "0.1"
      pong.build
    end
  end

end
