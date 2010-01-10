module Rubtella
  module Config

    # generating guid
    def self.generate_guid
      guid = Array.new
      16.times { guid << rand(255)}
      
      guid
    end

    IP_ADDRESS = "195.150.93.207"
    PORT = 54321
    GUID  = generate_guid

    
    
  end
end
