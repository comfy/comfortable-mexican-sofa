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
        Cms::Block.extend(MigrationsRequired)
        Cms::Layout.extend(MigrationsRequired)
        Cms::Snippet.extend(MigrationsRequired)
      end
    end
    
    module MigrationsRequired
      def find_by_identifier(*args)
        raise MigrationRequired, "This installation of ComfortableMexicanSofa needs to be migrated to a newer version. See: https://github.com/comfy/comfortable-mexican-sofa/wiki/Upgrading-ComfortableMexicanSofa"
      end
    end
  end
end