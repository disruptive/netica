require 'netica'
require 'rails'
module Netica
  class Railtie < Rails::Railtie
    rake_tasks do
      require "#{File.dirname(__FILE__)}/../tasks/netica.rake"
    end
  end
end