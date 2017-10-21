module ComfortableMexicanSofa::Seeds::Layout
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    def import!(path = self.path, parent = nil)
      Dir["#{path}*/"].each do |path|
        identifier = path.split('/').last

        layout = self.site.layouts.find_or_initialize_by(:identifier => identifier)
        layout.parent = parent

        # setting attributes
        if File.exist?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_seed?(layout, attrs_path)
            attrs = get_attributes(attrs_path)
            layout.label      = attrs['label']
            layout.app_layout = attrs['app_layout'] || parent.try(:app_layout)
            layout.position   = attrs['position'] if attrs['position']
          end
        end

        # setting content
        %w(html haml).each do |extension|
          if File.exist?(content_path = File.join(path, "content.#{extension}"))
            if fresh_seed?(layout, content_path)
              layout.content = extension == "html" ?
                ::File.open(content_path).read :
                Haml::Engine.new(::File.open(content_path).read).render.rstrip
            end
          end
        end

        if File.exist?(content_path = File.join(path, 'stylesheet.css'))
          if fresh_seed?(layout, content_path)
            layout.css = File.open(content_path).read
          end
        end
        if File.exist?(content_path = File.join(path, 'javascript.js'))
          if fresh_seed?(layout, content_path)
            layout.js = File.open(content_path).read
          end
        end

        # saving
        if layout.changed? || self.force_import
          if layout.save
            ComfortableMexicanSofa.logger.info("[CMS SEEDS] Imported Layout \t #{layout.identifier}")
          else
            ComfortableMexicanSofa.logger.warn("[CMS SEEDS] Failed to import Layout \n#{layout.errors.inspect}")
          end
        end

        self.seed_ids << layout.id

        # importing child layouts
        import!(path, layout)
      end

      # cleaning up
      unless parent
        self.site.layouts.where('id NOT IN (?)', self.seed_ids).each{ |s| s.destroy }
      end
    end
  end

  class Exporter < ComfortableMexicanSofa::Seeds::Exporter
    def export!
      prepare_folder!(self.path)

      self.site.layouts.each do |layout|
        layout_path = File.join(path, layout.ancestors.reverse.collect{|l| l.identifier}, layout.identifier)
        FileUtils.mkdir_p(layout_path)

        # writing attributes
        open(File.join(layout_path, 'attributes.yml'), 'w') do |f|
          f.write({
            'label'       => layout.label,
            'app_layout'  => layout.app_layout,
            'position'    => layout.position
          }.to_yaml)
        end
        open(File.join(layout_path, 'content.html'), 'w') do |f|
          f.write(layout.content)
        end
        open(File.join(layout_path, 'stylesheet.css'), 'w') do |f|
          f.write(layout.css)
        end
        open(File.join(layout_path, 'javascript.js'), 'w') do |f|
          f.write(layout.js)
        end

        ComfortableMexicanSofa.logger.info("[CMS SEEDS] Exported Layout \t #{layout.identifier}")
      end
    end
  end
end