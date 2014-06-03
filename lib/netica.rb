require 'java'

loaded_netica_j = false

locations = ['/Library/Java/Extensions/NeticaJ.jar', '/System/Library/Java/Extensions/NeticaJ.jar', '/usr/lib/java/NeticaJ.jar', '/lib/NeticaJ.jar']
locations.each do |fname| 
  if !loaded_netica_j && File.exists?(fname)
    begin
      require fname
      loaded_netica_j = true
    rescue LoadError
      puts "NeticaJ.jar not found at '#{fname}'"
    end
  end
end
  
raise "NeticaJ library files not found in #{locations}. See https://github.com/disruptive/netica for installation instructions." unless loaded_netica_j

require "netica/version"
require "netica/environ"
require "netica/environment"
require "netica/netica_logger"
require "netica/node"
require "netica/node_list"
require "netica/bayes_network"
require "netica/active_network"
require "netica/java_library_path"

module Netica
  include_package "norsys.netica"
  Java::NorsysNetica::Environ.__persistent__ = true
  require "netica/railtie" if defined?(Rails)
end
