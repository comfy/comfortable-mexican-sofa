module ComfortableMexicanSofa
  
  class Error < StandardError
  end
  
  class MissingPage < ComfortableMexicanSofa::Error
    def initialize(path)
      super "Cannot find CMS page at #{path}"
    end
  end
  
  class MissingLayout < ComfortableMexicanSofa::Error
    def initialize(slug)
      super "Cannot find CMS layout with slug: #{slug}"
    end
  end
end