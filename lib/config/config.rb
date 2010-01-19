module Rubtella
  module Config

    # generating guid
    def self.generate_guid
      guid = Array.new
      16.times { guid << rand(255)}
      
      guid
    end

    if File.exist?(ENV["HOME"] + "/.rubtella/config.rb")
      load ENV["HOME"] + "/.rubtella/config.rb"
    else
      Dir.mkdir(ENV['HOME'] + "/.rubtella") unless File.exist?(ENV['HOME'] + "/.rubtella")
      File.open(ENV["HOME"] + "/.rubtella/config.rb", 'w') do |f| 
        f.puts("#put your config here") 
        f.puts("#") 
        f.puts("# example below") 
        f.puts("#") 
        f.puts("#IP_ADDRESS = 127.0.0.1") 
        f.puts("#PORT = 54321") 
      end
    end

    IP_ADDRESS = "127.0.0.1" unless defined? IP_ADDRESS
    PORT = 54321 unless defined? PORT

    GUID  = generate_guid
    PID_FILE = ENV["HOME"] + "/.rubtella/rubtella.pid"

    
    
  end
end
