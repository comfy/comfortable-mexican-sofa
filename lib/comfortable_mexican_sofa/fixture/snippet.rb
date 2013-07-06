module ComfortableMexicanSofa::Fixture::Snippet
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    
    def import!
      Dir[self.path].each do |path|
        identifier = path.split('/').last
        snippet = self.site.snippets.find_or_initialize(:identifier => identifier)
        
        # setting attributes
        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_fixture?(snippet, attrs_path)
            attrs = get_attributes(attrs_path)
            snippet.label = attrs[:label]
          end
        end
        
        # setting content
        if File.exists?(content_path = File.join(path, 'content.html'))
          if fresh_fixture?(snippet, content_path)
            snippet.content = File.open(file_path).read
          end
        end
        
        # saving
        if snippet.changed?
          if snippet.save
            self.fixture_ids << snippet.id
            ComfortableMexicanSofa.logger.warn("[Fixtures] Saved Snippet {#{snippet.identifier}}")
          else
            ComfortableMexicanSofa.logger.warn("[Fixtures] Failed to save Snippet {#{snippet.errors.inspect}}")
          end
        end
      end
      
      # cleaning up
      self.site.snippets.where('id NOT IN (?)', fixture_ids).each{ |s| s.destroy }
      ComfortableMexicanSofa.logger.warn('Imported Snippets!')
    end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    
    def export!
      prepare_folder!(self.path)
      
      self.site.snippets.each do |snippet|
        snippet_path = File.join(self.path, snippet.identifier)
        prepare_folder!(snippet_path)
        
        # writing attributes
        open(File.join(snippet_path, 'attributes.yml'), 'w') do |f|
          f.write({:label => snippet.label}.to_yaml)
        end
        
        # writing content
        open(File.join(snippet_path, 'content.html'), 'w') do |f|
          f.write(snippet.content)
        end
      end
    end
  end
end