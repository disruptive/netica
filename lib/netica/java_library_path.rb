include Java
java_import java.lang.System

module Netica
  class Tools
    def self.library_path
      str = "Place NeticaJ.jar in one of the following locations:\n"
      System.getProperties["java.library.path"].split(':').each do |pth|
        str << "  => #{pth}\n" unless pth == '.'
      end
      str
    end
  end
end
