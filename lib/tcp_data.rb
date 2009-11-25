module Rubtella
  module TCPData
    class Builder
      attr_accessor :status, :header, :data

      def initialize status = "", header = nil, data = ""
        @status = String.new status
        @header = Hash.new header
        @data = String.new data
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


      attr_accessor :status, :headers, :data, :tcp_data, :peers

      def initialize tcp_data
        @tcp_data = tcp_data
        parse
      end

      def parse
        @headers = Hash.new
        @peers = Array.new

        headers, @data = @tcp_data.split("\r\n\r\n")
        headers = headers.split("\r\n")
        @status = headers.shift
        headers.each {|h| k,v = h.split(": "); @headers[k] = v}
        if up = @headers["X-Try-Ultrapeers"]
          up.split(",").each {|u| ip,port = u.split(":"); @peers << Peer.new(ip,port)}

        end
        
      end

      def ok?
        @status =~ /200 OK/
      end
    end
  end
end
