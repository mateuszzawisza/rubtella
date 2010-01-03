module Rubtella
  module TCPData
    class Base
      attr_accessor :guid, :payload_type, :ttl, :hops, :payload_lenght, :binary_data, :messages, :messages_codes, :rest

      @messages ={"\000" => "ping",
                  "\001" => "pong",
                  "\100" => "push",
                  "\200" => "query",
                  "\201" => "query"}

      @messages.default = "Unknown Payload Type"

      @messages_codes = {"ping" => 0,
                   "pong" => 1,
                   "push" => 64,
                   "query" => 128,
                   "query_hit" =>129}

      @messages_codes.default = "Unknown Payload Type"
    end 

    class Builder < Base
      def init_messages_codes
        @messages_codes = {"ping" => 0,
                     "pong" => 1,
                     "push" => 64,
                     "query" => 128,
                     "query_hit" =>129}

        @messages_codes.default = "Unknown Payload Type"
      end
  
                            
      def initialize       
        #initailze all stuff
          
          @guid = GUID
          @ttl = 5
          @hops = 0
          @payload_length = 0
      end

      def build
        @data = Array.new
        @guid = GUID
        @data = [@guid, @payload_type, @ttl, @hops, @payload_length, @payload]
        @data
      end

      #def self.build_guid
      #  f = open("/dev/urandom", "r")
      #  @guid = f.read(16)
      #  @guid
      #end

      def self.build_guid
        @guid = Array.new
        16.times { @guid << rand(255)}
        @guid
      end

      class Ping < Builder
      end

      class Pong < Builder

        attr_accessor :ip_address , :port

        def initialize args = nil
          init_messages_codes
          @payload_type = @messages_codes["pong"]

          super()

          @port = build_port PORT
          @ip_address = build_ip IP_ADDRESS
          @files_amount = [0,0,0]
          @files_size = [0,0,0]

        end

        def build
          @payload = [@port, @ip_address, @files_amount, @files_size]
          build = super
          @binary_data = build.flatten.pack("C*")
          @binary_data
        end

        def build_port(port)
          [port%256, port/256]# .pack("C*")
        end

        def build_ip(ip_address)
          ip_address.split(".").collect {|b| b.to_i} # .pack("C*")
        end
      end
    end

    class Parser < Base

      def initialize data 
        @binary_data = data
        parse 
      end

      def parse
        @guid = @binary_data[0..15]
        @payload_type = @binary_data[16..16]
        @ttl = @binary_data[17..17]
        @hops =  @binary_data[18..18]
        @payload_lenght = @binary_data[19..22]
        @payload = @binary_data[23..-1]
      end

      def message
        case @payload_type
        when "\000"
          "ping"
        when "\001"
          "pong"
        when "\100"
          "push"
        when "\200"
          "query"
        when "\201"
          "query"
        else
          raise "Unknown Payload Type"
        end
      end
    end
  end
end
