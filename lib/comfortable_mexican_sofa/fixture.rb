module ComfortableMexicanSofa::Fixture
  
  class Importer
    attr_accessor :site,
                  :path,
                  :from,
                  :to,
                  :fixture_ids,
                  :force_import
    
    def initialize(from, to = from, force_import = false)
      self.from         = from
      self.to           = to
      self.site         = Cms::Site.where(:identifier => to).first!
      self.fixture_ids  = []
      self.force_import = force_import
      
      dir = self.class.name.split('::')[2].downcase.pluralize
      self.path = ::File.join(ComfortableMexicanSofa.config.fixtures_path, from, dir, '/')
    end
    
    def fresh_fixture?(object, file_path)
      object.new_record? || self.force_import || ::File.mtime(file_path) > object.updated_at
    end
    
    def get_attributes(file_path)
      YAML.load_file(file_path)
    end
    
    def save_categorizations!(object, categories)
      object.categorizations.delete_all
      [categories].flatten.compact.each do |label|
        category = self.site.categories.find_or_create_by(
          :label            => label,
          :categorized_type => object.class.to_s
        )
        category.categorizations.create!(
          :categorized => object
        )
      end
    end
    
    def read_as_haml(path)
      content = ::File.open(path).read
      Haml::Engine.new(content).render.rstrip
    rescue # Bad haml, calls to helpers, who knows?
      content
    end
    
    def import!
      ComfortableMexicanSofa::Fixture::Category::Importer.new(from, to, force_import).import!
      ComfortableMexicanSofa::Fixture::File::Importer.new(    from, to, force_import).import!
      ComfortableMexicanSofa::Fixture::Layout::Importer.new(  from, to, force_import).import!
      ComfortableMexicanSofa::Fixture::Page::Importer.new(    from, to, force_import).import!
      ComfortableMexicanSofa::Fixture::Snippet::Importer.new( from, to, force_import).import!
    end
  end
  
  class Exporter
    attr_accessor :site,
                  :path,
                  :from,
                  :to
    
    def initialize(from, to = from)
      self.from = from
      self.to   = to
      self.site = Cms::Site.where(:identifier => from).first!
      dir = self.class.name.split('::')[2].downcase.pluralize
      self.path = ::File.join(ComfortableMexicanSofa.config.fixtures_path, to, dir)
    end
    
    def prepare_folder!(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
    
    def export!
      ComfortableMexicanSofa::Fixture::File::Exporter.new(    from, to).export!
      ComfortableMexicanSofa::Fixture::Category::Exporter.new(from, to).export!
      ComfortableMexicanSofa::Fixture::Layout::Exporter.new(  from, to).export!
      ComfortableMexicanSofa::Fixture::Page::Exporter.new(    from, to).export!
      ComfortableMexicanSofa::Fixture::Snippet::Exporter.new( from, to).export!
    end
  end
  
end