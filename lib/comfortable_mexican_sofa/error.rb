module ComfortableMexicanSofa
  
  class Error < StandardError
  end
  
  class MissingSite < ComfortableMexicanSofa::Error
    def initialize(slug)
      super "Cannot find CMS Site with slug: #{slug}"
    end
  end
  
  class MissingLayout < ComfortableMexicanSofa::Error
    def initialize(slug)
      super "Cannot find CMS Layout with slug: #{slug}"
    end
  end
  
  class MissingPage < ComfortableMexicanSofa::Error
    def initialize(path)
      super "Cannot find CMS Page at #{path}"
    end
  end
  
end