module ComfortableMexicanSofa::Seeds::Snippet
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    def import!
      Dir["#{self.path}*/"].each do |path|
        identifier = path.split('/').last
        snippet = self.site.snippets.find_or_initialize_by(:identifier => identifier)

        # setting attributes
        categories = []
        if File.exist?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_seed?(snippet, attrs_path)
            attrs = get_attributes(attrs_path)

            snippet.label = attrs['label']
            categories    = attrs['categories']
          end
        end

        # setting content
        %w(html haml).each do |extension|
          if File.exist?(content_path = File.join(path, "content.#{extension}"))
            if fresh_seed?(snippet, content_path)
              snippet.content = extension == "html" ?
                ::File.open(content_path).read :
                Haml::Engine.new(::File.open(content_path).read).render.rstrip
            end
          end
        end

        # saving
        if snippet.changed? || self.force_import
          if snippet.save
            save_categorizations!(snippet, categories)
            ComfortableMexicanSofa.logger.info("[CMS SEEDS] Imported Snippet \t #{snippet.identifier}")
          else
            ComfortableMexicanSofa.logger.warn("[CMS SEEDS] Failed to import Snippet \n#{snippet.errors.inspect}")
          end
        end

        self.seed_ids << snippet.id
      end

      # cleaning up
      self.site.snippets.where('id NOT IN (?)', seed_ids).each{ |s| s.destroy }
    end
  end

  class Exporter < ComfortableMexicanSofa::Seeds::Exporter

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

        ComfortableMexicanSofa.logger.info("[CMS SEEDS] Exported Snippet \t #{snippet.identifier}")
      end
    end
  end
end
