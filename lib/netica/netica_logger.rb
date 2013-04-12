module Netica
  class NeticaLogger
    require 'logger'
    require 'date'

    def self.info(message=nil)
      self.logfile.info("[Netica #{DateTime.now}] #{message}") unless message.nil?
    end

    def self.debug(message=nil)
      self.logfile.debug("[Netica #{DateTime.now}] #{message}") unless message.nil?
    end

    def self.start_logging(filepath = "netica.log")
      file = File.open(filepath, File::WRONLY | File::APPEND)
      @@my_log = Logger.new(file)
    end

    def self.logfile
      @@my_log
    end
  end
end