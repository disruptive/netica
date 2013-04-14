module Netica
  class NeticaLogger
    require 'logger'
    require 'date'

    def self.info(message=nil)
      self.logfile.info(message) unless message.nil?
    end

    def self.debug(message=nil)
      self.logfile.debug(message) unless message.nil?
    end

    def self.logfile
      @@my_log ||= Logger.new(File.open(Netica::Environment.instance.logfile_path, File::WRONLY | File::APPEND))
    end
  end
end