require "bundler/gem_tasks"
require 'rspec'
require 'rspec/core/rake_task'

load "lib/tasks/netica.rake"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format progress --colour)
end