require 'logger'

module RubtellaLogger
  
  def self.init_logger
    log = Logger.new('log/rubtella.log')
    log.level = Logger::INFO
    log.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
    return log
  end

end

@@logger = RubtellaLogger.init_logger