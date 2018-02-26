# frozen_string_literal: true

module ComfortableMexicanSofa::Seeds::Layout
  class Exporter < ComfortableMexicanSofa::Seeds::Exporter

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, to, "layouts/")
    end

    def export!
      prepare_folder!(path)

      site.layouts.each do |layout|
        layout_path = File.join(path, layout.ancestors.reverse.collect(&:identifier), layout.identifier)
        FileUtils.mkdir_p(layout_path)

        path = ::File.join(layout_path, "content.html")
        data = []

        attrs = {
          "label"      => layout.label,
          "app_layout" => layout.app_layout,
          "position"   => layout.position
        }.to_yaml

        data << { header: "attributes",  content: attrs }
        data << { header: "content",     content: layout.content }
        data << { header: "js",          content: layout.js }
        data << { header: "css",         content: layout.css }

        write_file_content(path, data)

        message = "[CMS SEEDS] Exported Layout \t #{layout.identifier}"
        ComfortableMexicanSofa.logger.info(message)
      end
    end

  end
end
