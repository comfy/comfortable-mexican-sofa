module ComfortableMexicanSofa::Fixture::Snippet
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
