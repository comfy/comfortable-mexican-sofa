module ComfortableMexicanSofa::Fixture::Layout
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    
    def import!(path = self.path, parent = nil)
      Dir[path].each do |path|
        identifier = path.split('/').last
        layout = self.site.layouts.find_or_initialize(:identifier => identifier)
        
        # setting attributes
        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_fixture?(layout, attrs_path)
            attrs = get_attributes(attrs_path)
            layout.label      = attrs[:label]
            layout.app_layout = attrs[:app_layout] || parent.try(:app_layout)
            layout.position   = attrs[:position] if attributes[:position]
          end
        end
        
        # setting content
        if File.exists?(content_path = File.join(path, 'content.html'))
          if fresh_fixture?(layout, content_path)
            layout.content = File.open(file_path).read
          end
        end
        if File.exists?(content_path = File.join(path, 'stylesheet.css'))
          if fresh_fixture?(layout, content_path)
            layout.css = File.open(file_path).read
          end
        end
        if File.exists?(content_path = File.join(path, 'javascript.js'))
          if fresh_fixture?(layout, content_path)
            layout.js = File.open(file_path).read
          end
        end
        
        # saving
        if layout.changed?
          if layout.save
            self.fixture_ids << layout.id
            ComfortableMexicanSofa.logger.warn("[Fixtures] Saved Layout {#{layout.identifier}}")
          else
            ComfortableMexicanSofa.logger.warn("[Fixtures] Failed to save Layout {#{snippet.errors.inspect}}")
          end
        end
        
        import!(path, layout)
      end
      
      # cleaning up
      unless parent
        self.site.layouts.where('id NOT IN (?)', self.fixture_ids).each{ |s| s.destroy }
        ComfortableMexicanSofa.logger.warn('Imported Layouts!')
      end
    end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)
      
      self.site.layouts.each do |layout|
        layout_path = File.join(path, layout.ancestors.reverse.collect{|l| l.identifier}, layout.identifier)
        prepare_folder!(layout_path)
        
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
      end
    end
  end
end