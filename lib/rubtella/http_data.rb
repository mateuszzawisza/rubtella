module Rubtella
  module HTTPData
    class Builder
      attr_accessor :status, :headers, :data

      def initialize status = "", headers = nil, data = ""
        @status = String.new status
        @headers = headers
        @data = String.new data
      end

      def build
        @http_data = Array.new
        @http_data << @status
        @http_data << "\r\n"
        @headers.each {|k,v|  @http_data << "#{k}: #{v}\r\n"}
        @http_data << "\r\n"
        @http_data << @data
        @http_data.to_s
      end
    end

    class Parser


      attr_accessor :status, :headers, :data, :http_data, :peers

      def initialize http_data
        @http_data = http_data
        parse
      end

      def parse
        @headers = Hash.new
        @peers = Array.new

        headers, @data = @http_data.split("\r\n\r\n")
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
