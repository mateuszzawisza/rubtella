#!/usr/bin/ruby  
# ruby gnutella client

require 'socket'  
require 'timeout'
require 'rubtella/logger'
require 'rubygems'
require 'ruby-debug'



module Rubtella
  
  GNUTELLA_REQUEST = "GNUTELLA CONNECT/0.6"
  GNUTELLA_RESPONSE_OK = "GNUTELLA/0.6 200 OK"
  
   

  class Listener

    include Socket::Constants

    #listen for connection
    def listen
      server = TCPServer.new("0.0.0.0", PORT)  
      
        
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
        timeout(5) do 
          stream.send handshake_req, 0
        end
        @response = stream.recv 1000
      
        resp = HTTPData::Parser.new @response 
        stream.send handshake_resp, 0

        if resp.ok?
          #connection established
          puts 'connection established'
          @connected = @peer
          puts "Connected with #{@connected.ip} #{@connected.port}"
          @@logger.info "Connected with #{@connected.ip} #{@connected.port}"
          
          manage_connection stream
        else
          puts 'failed to connect'
          @peer = resp.peers.shift
          connect
        end
      rescue Timeout::Error
        @peer = resp.peers.shift
        connect
      rescue => e
        @@logger.info e.to_s
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
        puts 'we\'re listening..'
        resp = stream.recv 1000
        if parse(resp) == "ping"
          pong = TCPData::Builder::Pong.new
          stream.send pong.build , 0 
          puts 'pong send..'
          stream.close
          puts 'connection closed'
          break
        end
      end 

      

    end
    
    def parse message
      parsed = TCPData::Parser.new message
      puts parsed.message
      
      parsed.message

    end

    def send_query(text)
      stream = TCPSocket.new @connected.ip, @connected.port
      query = TCPData::Builder::Query.new(:criteria => text)
      @@logger.info "sending query - #{text}"
      stream.send query.build, 0
      puts 'we\'re listening..'
      resp = stream.recv 1000
      parse(resp)
    end
  end

end
