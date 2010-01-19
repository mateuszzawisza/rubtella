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
             manage_connection session
           rescue => e
             session.puts "Rubtella Listener Error: " + e.to_s
             @@logger.info "Rubtella Server Error: " + e.to_s
           ensure
             session.close
           end

         end
      end   #end loop 
    end
      
    def manage_connection stream
      loop do
        @@logger.info 'we\'re listening..'
        resp = stream.recv 1000
        if parse(resp) == "ping"
          pong = TCPData::Builder::Pong.new
          stream.send pong.build , 0 
          @@logger.info 'pong send..'
          stream.close
          @@logger.info 'connection closed'
          break
        end
      end 

    end

  end

  class Sender


    attr_accessor :peer, :connected
    
    def initialize peer = nil
      @peers = Array.new
      init_peers 

      if peer
        @peers << peer
      end

      raise RubtellaError, "No peer address! Pleas add peers to hosts file!" if @peers.empty?

      @peer = @peers.pop

      @standard_headers = {"User-Agent" => "Rubtella",
                           "X-Ultrapeer" => "False",
                           "X-Query-Routing" => "0.1"}

    rescue => e
      @@logger.info e.to_s
    end

    def connect
      @@logger.info "connecting to: #{@peer.ip}:#{@peer.port}"
      stream = nil
      timeout(5) do 
        stream = TCPSocket.new @peer.ip, @peer.port
        stream.send handshake_req, 0
      end
      @response = stream.recv 1000
      
      resp = HTTPData::Parser.new @response 
      stream.send handshake_resp, 0

      if resp.ok?
        #connection established
        @@logger.info 'connection established'
        @connected = @peer
        @@logger.info "Connected with #{@connected.ip} #{@connected.port}"
        
        manage_connection stream
      else
        @@logger.info 'failed to connect'
        @peers.concat resp.peers
        @peer = @peers.pop
        connect
      end
    rescue Timeout::Error,Errno::ECONNREFUSED
      @@logger.info "Timeout"
      @peer = @peers.shift
      retry
    rescue => e
      @@logger.info e.to_s
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
        @@logger.info 'we\'re listening..'
        resp = stream.recv 1000
        if parse(resp) == "ping"
          pong = TCPData::Builder::Pong.new
          stream.send pong.build , 0 
          @@logger.info 'pong send..'
          stream.close
          @@logger.info 'connection closed'
          break
        end
      end 

      

    end
    
    def parse message
      parsed = TCPData::Parser.new message
      @@logger.info parsed.message
      
      parsed.message

    end

    def send_ping
      stream = TCPSocket.new @connected.ip, @connected.port
      query = TCPData::Builder::Ping.new
      @@logger.info "sending ping"
      stream.send query.build, 0
      @@logger.info 'we\'re listening..'
      resp = stream.recv 1000
      parse(resp)
    end

    def send_query(text)
      stream = TCPSocket.new @connected.ip, @connected.port
      query = TCPData::Builder::Query.new(:criteria => text)
      @@logger.info "sending query - #{text}"
      stream.send query.build, 0
      @@logger.info 'we\'re listening..'
      resp = stream.recv 1000
      parse(resp)
    end

    def init_peers
      if File.exist?(ENV["HOME"] + "/.rubtella/hosts")
        hosts_file = File.open ENV["HOME"] + "/.rubtella/hosts"
        hosts = hosts_file.read
        hosts.split("\n")
        hosts.each {|h| @peers << Peer.new(*(h.split(":")))}
      end
    end
  end

end
