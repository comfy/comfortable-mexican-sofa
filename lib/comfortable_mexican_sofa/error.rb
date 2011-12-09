module ComfortableMexicanSofa
  
  class Error < StandardError
  end
  
  class MissingSite < ComfortableMexicanSofa::Error
    def initialize(identifier)
      super "Cannot find CMS Site with identifier: #{identifier}"
    end
  end
  
  class MissingLayout < ComfortableMexicanSofa::Error
    def initialize(identifier)
      super "Cannot find CMS Layout with identifier: #{identifier}"
    end
  end
  
  class MissingPage < ComfortableMexicanSofa::Error
    def initialize(path)
      super "Cannot find CMS Page at #{path}"
    end
  end
  
end