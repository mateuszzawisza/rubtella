require 'config/config'

module Rubtella
  module TCPData
    class Base
      include Rubtella::Config
      attr_accessor :guid, :payload_type, :ttl, :hops, :payload_lenght, :binary_data, :messages, :messages_codes, :rest

      @messages ={"\000" => "ping",
                  "\001" => "pong",
                  "\100" => "push",
                  "\200" => "query",
                  "\201" => "query_hit"}

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
          init_messages_codes
          
          @guid = GUID
          @ttl = 5
          @hops = 0
          @payload_length = 0
      end

      def build
        @data = Array.new
        @guid = GUID
        
        build_message

        @data = [@guid, @payload_type, @ttl, @hops, @payload_length, @payload]

        @binary_data = @data.flatten.pack("C*")
        @binary_data
      end

      def build_message
        # this method needs to be implemented by a child class
        @payload = []
      end
      

      class Ping < Builder
        def initialize args = nil
          super()

          @payload_type = @messages_codes["ping"]
        end
      end

      class Pong < Builder

        attr_accessor :ip_address , :port

        def initialize args = nil
          super()

          @payload_type = @messages_codes["pong"]
          @port = build_port PORT
          @ip_address = build_ip IP_ADDRESS
          @files_amount = [0,0,0]
          @files_size = [0,0,0]

        end

        def build_message
          @payload = [@port, @ip_address, @files_amount, @files_size]
        end

        def build_port(port)
          [port%256, port/256]# .pack("C*")
        end

        def build_ip(ip_address)
          ip_address.split(".").collect {|b| b.to_i} # .pack("C*")
        end
      end

      class Query < Builder

          def initialize args = nil

            super()

            @payload_type = @messages_codes["query"]
            @speed = 0
            @criteria = args.is_a?(Hash) ? args[:criteria] : ""

          end

          def build_message
            @payload = [@speed, @criteria.unpack("C*")]
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
