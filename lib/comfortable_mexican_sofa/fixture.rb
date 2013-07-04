module ComfortableMexicanSofa::Fixture
  class Importer
    attr_accessor :site, :fixtures_path, :fixture_ids
    
    def initialize(from, to = from)
      self.fixture_ids = []
      
      self.site = Cms::Site.where(:identifier => to).first!
      
      dir = self.class.name.split('::')[2].downcase.pluralize
      self.path = File.join(ComfortableMexicanSofa.config.fixtures_path, from, dir)
      raise Errno::ENOENT "Cannot find fixtures for #{dir}" unless File.directory?(self.path)
    end
    
    def fresh_fixture?(object, file_path)
      File.mtime(file_path) > object.updated_at
    end
    
    def get_attributes(file_path)
      YAML.load_file(file_path).try(:symbolize_keys!) || { }
    end
  end
  
  class Exporter
    attr_accessor :site
    
    def initialize(to, from = to)
      self.site = Cms::Site.where(:identifier => from).first
      dir = self.class.name.split('::')[2].downcase.pluralize
      self.path = File.join(ComfortableMexicanSofa.config.fixtures_path, to, dir)
    end
    
    def prepare_folder!(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
  end
end