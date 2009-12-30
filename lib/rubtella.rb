#!/usr/bin/ruby  
# ruby gnutella client

require 'socket'  
require 'timeout'
require 'lib/logger'



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


    attr_accessor :peer, :connected
    
    def initialize peer
      @peer = peer
      @standard_headers = {"User-Agent" => "Rubtella",
                           "X-Ultrapeer" => "False",
                           "X-Query-Routing" => "0.1"}
    end

    def connect
      begin
        puts "connecting to: #{@peer.ip}:#{@peer.port}"
        stream = TCPSocket.new @peer.ip, @peer.port
        Timeout::timeout(5) {stream.send handshake_req, 0}
        @response = stream.recv 1000
      
        resp = HTTPData::Parser.new @response 
        stream.send handshake_resp, 0

        if resp.ok?
          #connection established
          @connected = @peer
          puts "Connected with #{@connected.ip} #{@connected.port}"
          @@logger.info "Connected with #{@connected.ip} #{@connected.port}"
          
          manage_connection stream
        else
          @peer = resp.peers.shift
          connect
        end
      rescue Timeout::Error
        @peer = resp.peers.shift
        connect
      end
    end

    def handshake_req
     req = HTTPData::Builder.new GNUTELLA_REQUEST, @standard_headers
     req.build
    end

    def handshake_resp
      resp = HTTPData::Builder.new GNUTELLA_RESPONSE_OK, @standard_headers
      resp.build
    end
    
    def manage_connection stream
      loop do
        resp = stream.recv 1000
        @@logger.info resp
        puts parse(resp)
      end 
    end
    
    def parse message
      parsed = TCPData::Parser.new message
      parsed.message
    end
  end

end
