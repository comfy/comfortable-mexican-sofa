module ComfortableMexicanSofa
  
  class Error < StandardError
  end
  
  class MissingPage < ComfortableMexicanSofa::Error
    def initialize(path)
      super "Cannot find CMS page at #{path}"
    end
  end
end