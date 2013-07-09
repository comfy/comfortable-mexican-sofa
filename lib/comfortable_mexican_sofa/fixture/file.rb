module ComfortableMexicanSofa::Fixture::File
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def import!
      Dir["#{self.path}[^_]*"].each do |file_path|
        filename = ::File.basename(file_path)
        file = self.site.files.where(:file_file_name => filename).first || self.site.files.new
        
        # setting attributes
        categories = []
        if File.exists?(attrs_path = File.join(self.path, "_#{filename}.yml"))
          if fresh_fixture?(file, attrs_path)
            attrs = get_attributes(attrs_path)
            file.label        = attrs['label']
            file.description  = attrs['description']
            categories        = attrs['categories']
          end
        end
        
        # setting actual file
        if fresh_fixture?(file, file_path)
          file.file = open(file_path)
        end
        
        if file.changed? || self.force_import
          if file.save
            save_categorizations!(file, categories)
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Imported File \t #{file.file_file_name}")
          else
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import File \n#{file.errors.inspect}")
          end
        end
        
        self.fixture_ids << file.id
      end
      
      # cleaning up
      self.site.files.where('id NOT IN (?)', fixture_ids).each{ |s| s.destroy }
    end
  end
  
  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)
      
      self.site.files.each do |file|
        file_path = File.join(self.path, file.file_file_name)
        
        # writing attributes
        open(::File.join(self.path, "_#{file.file_file_name}.yml"), 'w') do |f|
          f.write({
            'label'       => file.label,
            'description' => file.description,
            'categories'  => file.categories.map{|c| c.label}
          }.to_yaml)
        end
        
        # writing content
        data_path = file.file.options[:storage] == :filesystem ?
          file.file.path :
          file.file.url
          
        open(::File.join(self.path, ::File.basename(file_path)), 'w') do |f|
          f.write(open(data_path))
        end
        
        ComfortableMexicanSofa.logger.warn("[FIXTURES] Exported File \t #{file.file_file_name}")
      end
    end
  end
end