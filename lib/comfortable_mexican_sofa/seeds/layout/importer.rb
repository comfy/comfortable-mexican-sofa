# frozen_string_literal: true

module ComfortableMexicanSofa::Seeds::Layout
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, from, "layouts/")
    end

    def import!(path = self.path, parent = nil)
      Dir["#{path}*/"].each do |layout_path|
        import_layout(layout_path, parent)
      end

      # cleaning up
      site.layouts.where("id NOT IN (?)", seed_ids).destroy_all
    end

  private

    def import_layout(path, parent)
      identifier = path.split("/").last

      # reading file content in, resulting in a hash
      content_path = File.join(path, "content.html")
      content_hash = parse_file_content(content_path)

      # parsing attributes section
      attributes_yaml = content_hash.delete("attributes")
      attrs           = YAML.safe_load(attributes_yaml)

      layout = site.layouts.where(identifier: identifier).first_or_initialize
      layout.parent = parent

      if fresh_seed?(layout, content_path)
        layout.attributes = attrs.merge(
          app_layout: attrs["app_layout"] || parent.try(:app_layout),
          content:    content_hash["content"],
          js:         content_hash["js"],
          css:        content_hash["css"]
        )

        if layout.save
          message = "[CMS SEEDS] Imported Layout \t #{layout.identifier}"
          ComfortableMexicanSofa.logger.info(message)
        else
          message = "[CMS SEEDS] Failed to import Layout \n#{layout.errors.inspect}"
          ComfortableMexicanSofa.logger.warn(message)
        end
      end

      seed_ids << layout.id

      # importing child layouts (if there are any)
      Dir["#{path}*/"].each do |layout_path|
        import_layout(layout_path, layout)
      end
    end

  end
end
