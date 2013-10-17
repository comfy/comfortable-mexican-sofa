module ComfortableMexicanSofa::Fixture::Page
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    
    attr_accessor :target_pages
    
    def import!(path = self.path, parent = nil)
      Dir["#{path}*/"].each do |path|
        slug = path.split('/').last
        
        page = if parent
          parent.children.where(:slug => slug).first || site.pages.new(:parent => parent, :slug => slug)
        else
          site.pages.root || site.pages.new(:slug => slug)
        end
        
        # setting attributes
        categories = []
        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_fixture?(page, attrs_path)
            attrs = get_attributes(attrs_path)
            
            page.label        = attrs['label']
            page.layout       = site.layouts.where(:identifier => attrs['layout']).first || parent.try(:layout)
            page.is_published = attrs['is_published'].nil?? true : attrs['is_published']
            page.position     = attrs['position'] if attrs['position']
            
            categories        = attrs['categories']
            
            if attrs['target_page']
              self.target_pages ||= {}
              self.target_pages[page] = attrs['target_page']
            end
          end
        end
        
        # setting content
        blocks_to_clear = page.blocks.collect(&:identifier)
        blocks_attributes = [ ]
        Dir.glob("#{path}/*.html").each do |block_path|
          identifier = block_path.split('/').last.gsub(/\.html\z/, '')
          blocks_to_clear.delete(identifier)
          if fresh_fixture?(page, block_path)
            blocks_attributes << {
              :identifier => identifier,
              :content    => read_as_haml(block_path)
            }
          end
        end
        
        # deleting removed blocks
        page.blocks.where(:identifier => blocks_to_clear).destroy_all
        
        page.blocks_attributes = blocks_attributes if blocks_attributes.present?
        
        # saving
        if page.changed? || page.blocks_attributes_changed || self.force_import
          if page.save
            save_categorizations!(page, categories)
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Imported Page \t #{page.full_path}")
          else
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import Page \n#{page.errors.inspect}")
          end
        end
        
        self.fixture_ids << page.id
        
        # importing child pages
        import!(path, page)
      end
      
      # linking up target pages
      if self.target_pages.present?
        self.target_pages.each do |page, target|
          if target_page = self.site.pages.where(:full_path => target).first
            page.target_page = target_page
            page.save
          end
        end
      end
      
      # cleaning up
      unless parent
        self.site.pages.where('id NOT IN (?)', self.fixture_ids).each{ |s| s.destroy }
      end
    end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)
      
      self.site.pages.each do |page|
        page.slug = 'index' if page.slug.blank?
        page_path = File.join(path, page.ancestors.reverse.collect{|p| p.slug.blank?? 'index' : p.slug}, page.slug)
        FileUtils.mkdir_p(page_path)

        open(File.join(page_path, 'attributes.yml'), 'w') do |f|
          f.write({
            'label'         => page.label,
            'layout'        => page.layout.try(:identifier),
            'parent'        => page.parent && (page.parent.slug.present?? page.parent.slug : 'index'),
            'target_page'   => page.target_page.try(:full_path),
            'categories'    => page.categories.map{|c| c.label},
            'is_published'  => page.is_published,
            'position'      => page.position
          }.to_yaml)
        end
        page.blocks_attributes.each do |block|
          open(File.join(page_path, "#{block[:identifier]}.html"), 'w') do |f|
            f.write(block[:content])
          end
        end
        
        ComfortableMexicanSofa.logger.warn("[FIXTURES] Exported Page \t #{page.full_path}")
      end
    end
  end
end
