module Rubtella
  class Peer
    attr_accessor :ip, :port

    def initialize(ip, port)
      @ip = ip
      @port = port.to_i
    end

  end
end
