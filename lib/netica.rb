require 'java'
require '/lib/NeticaJ.jar'

require "netica/version"
require "netica/environ"
require "netica/environment"
require "netica/netica_logger"
require "netica/node"
require "netica/node_list"
require "netica/bayes_network"
require "netica/active_network"
require "netica/storable_network"
require "netica/java_library_path"

module Netica
  include_package "norsys.netica"
  Java::NorsysNetica::Environ.__persistent__ = true
  require "netica/railtie" if defined?(Rails)
end
