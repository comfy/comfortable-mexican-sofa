module ComfortableMexicanSofa::Fixture::Snippet
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    
    def import!
      Dir["#{self.path}*/"].each do |path|
        identifier = path.split('/').last
        snippet = self.site.snippets.find_or_initialize_by(:identifier => identifier)
        
        # setting attributes
        categories = []
        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_fixture?(snippet, attrs_path)
            attrs = get_attributes(attrs_path)
            
            snippet.label = attrs['label']
            categories    = attrs['categories']
          end
        end
        
        # setting content
        if File.exists?(content_path = File.join(path, 'content.html'))
          if fresh_fixture?(snippet, content_path)
            snippet.content = read_as_haml(content_path)
          end
        end
        
        # saving
        if snippet.changed? || self.force_import
          if snippet.save
            save_categorizations!(snippet, categories)
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Imported Snippet \t #{snippet.identifier}")
          else
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import Snippet \n#{snippet.errors.inspect}")
          end
        end
        
        self.fixture_ids << snippet.id
      end
      
      # cleaning up
      self.site.snippets.where('id NOT IN (?)', fixture_ids).each{ |s| s.destroy }
    end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    
    def export!
      prepare_folder!(self.path)
      
      self.site.snippets.each do |snippet|
        snippet_path = File.join(self.path, snippet.identifier)
        FileUtils.mkdir_p(snippet_path)
        
        # writing attributes
        open(File.join(snippet_path, 'attributes.yml'), 'w') do |f|
          f.write({
            'label'       => snippet.label,
            'categories'  => snippet.categories.map{|c| c.label}
          }.to_yaml)
        end
        
        # writing content
        open(File.join(snippet_path, 'content.html'), 'w') do |f|
          f.write(snippet.content)
        end
        
        ComfortableMexicanSofa.logger.warn("[FIXTURES] Exported Snippet \t #{snippet.identifier}")
      end
    end
  end
end