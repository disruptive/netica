require "#{File.dirname(__FILE__)}/../netica/java_library_path"

namespace :netica do
  desc "Output java.library.path"
  task :java_library_path do
    puts Netica::Tools.library_path
  end
end