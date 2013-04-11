module Netica
  class NeticaLogger
    def self.info(message=nil)
      p message
      #self.logfile.info("[Netica #{DateTime.now}] #{message}") unless message.nil?
    end

    def self.debug(message=nil)
      p message
      #self.logfile.debug("[Netica #{DateTime.now}] #{message}") unless message.nil?
    end

    # def self.logfile
    #   @@my_log ||= Logger.new("#{File.dirname(__FILE__)}/log/netica.log")
    # end
  end
end