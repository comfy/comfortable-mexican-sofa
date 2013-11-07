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
end
