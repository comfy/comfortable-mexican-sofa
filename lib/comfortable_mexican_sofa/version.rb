module ComfortableMexicanSofa
  VERSION = begin 
    IO.read(File.join(File.dirname(__FILE__), '/../../VERSION')).chomp
  rescue
    'UNKNOWN'
  end
  
  module Version
    def self.check!
      # Test for presence of new 1.6.x columns
      unless (Cms::Page.columns.find { |c| c.name == 'identifier' })
        raise ComfortableMexicanSofa::MigrationRequired
      end
    end
  end
end