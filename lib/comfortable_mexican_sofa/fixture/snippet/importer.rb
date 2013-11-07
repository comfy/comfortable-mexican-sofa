module ComfortableMexicanSofa::Fixture::Snippet
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def import!
      Dir["#{self.path}*/"].each do |path|
        identifier = File.basename path
        snippets = self.site.snippets
        snippet = snippets.find_or_initialize_by(identifier: identifier)

        categories = import_attributes! snippet, path
        import_content! snippet, path

        if snippet.changed? || self.force_import
          save_snippet snippet, categories
        end

        self.fixture_ids << snippet.id
      end

      # cleaning up
      self.site.snippets.where('id NOT IN (?)', fixture_ids).each{ |s| s.destroy }
    end

    private
    def import_attributes! snippet, path
      categories = []
      if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
        if fresh_fixture?(snippet, attrs_path)
          attrs = get_attributes(attrs_path)

          snippet.label = attrs['label']
          categories    = attrs['categories']
        end
      end
      categories
    end

    def import_content! snippet, path
      if File.exists?(content_path = File.join(path, 'content.html')) &&
        fresh_fixture?(snippet, content_path)

        snippet.content = read_as_haml(content_path)
      end
    end

    def save_snippet snippet, categories
      if snippet.save
        save_categorizations!(snippet, categories)
        ComfortableMexicanSofa.logger.warn(
          "[FIXTURES] Imported Snippet \t #{snippet.identifier}")
      else
        ComfortableMexicanSofa.logger.warn(
          "[FIXTURES] Failed to import Snippet \n#{snippet.errors.inspect}")
      end
    end

  end
end
