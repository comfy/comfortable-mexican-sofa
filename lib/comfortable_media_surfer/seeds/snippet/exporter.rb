# frozen_string_literal: true

module ComfortableMediaSurfer::Seeds::Snippet
  class Exporter < ComfortableMediaSurfer::Seeds::Exporter
    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMediaSurfer.config.seeds_path, to, 'snippets/')
    end

    def export!
      prepare_folder!(path)

      site.snippets.each do |snippet|
        attrs = {
          'label' => snippet.label,
          'categories' => snippet.categories.map(&:label),
          'position' => snippet.position
        }.to_yaml

        data = []
        data << { header: 'attributes', content: attrs }
        data << { header: 'content', content: snippet.content }

        snippet_path = File.join(path, "#{snippet.identifier}.html")
        write_file_content(snippet_path, data)

        message = "[CMS SEEDS] Exported Snippet \t #{snippet.identifier}"
        ComfortableMediaSurfer.logger.info(message)
      end
    end
  end
end
