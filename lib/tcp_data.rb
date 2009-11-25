module Rubtella
  module TCPData
    class Builder
      attr_accessor :status,:header, :data

      def initialize
        @status = String.new
        @header = Hash.new
        @data = String.new
      end

      def build
        @tcp_data = Array.new
        @tcp_data << @status
        @tcp_data << "\r\n"
        @header.each {|k,v|  @tcp_data << "#{k}: #{v}\r\n"}
        @tcp_data << "\r\n"
        @tcp_data << @data
        @tcp_data.to_s
      end
    end

    class Parser


      attr_accessor :status,:headers,:data, :tcp_data

      def initialize tcp_data
        @tcp_data = tcp_data
        parse
      end

      def parse
        @headers = Hash.new

        headers, @data = @tcp_data.split("\r\n\r\n")
        headers = headers.split("\r\n")
        @status = headers.shift
        headers.each {|h| k,v = h.split(":"); @headers[k] = v.strip}
      end
    end
  end
end
