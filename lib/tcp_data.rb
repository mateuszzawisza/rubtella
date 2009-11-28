module Rubtella
  module TCPData
    class Base
      attr_accessor :guid, :payload_type, :ttl, :hops, :payload_lenght, :binary_data
    end 

    class Builder < Base

                            
      def initialize       
      end

      def build
        @data = Array.new
        @data = [@guid, @payload_type, @ttl, @hops, @payload_lenght]
        @binary_data = @data.to_s
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
