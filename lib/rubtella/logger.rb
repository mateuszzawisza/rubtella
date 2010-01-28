require 'rubygems'
require 'ruby-growl'
require 'logger'

class RubtellaLogger

  def initialize
    @rubylogger = init_logger
    @growl = init_growl
  end
  
  def init_logger
    Dir.mkdir(ENV['HOME'] + "/.rubtella") unless File.exist?(ENV['HOME'] + "/.rubtella")
    log = Logger.new(ENV['HOME'] + "/.rubtella/rubtella.log")
    log.level = Logger::INFO
    log.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
    return log
  end

  def init_growl
    g = Growl.new "localhost", "rubtela",
                  ["rubtella log"]
    return g
  end

  def info(message)
    begin
      @rubylogger.info message
      #@growl.notify "rubtella log", "Rubtella", message
    rescue
      puts 'logger error'
    end
  end

end

@@logger = RubtellaLogger.new
