module ComfortableMexicanSofa::Seeds::Page
  class Importer < ComfortableMexicanSofa::Seeds::Importer

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
        if File.exist?(attrs_path = File.join(path, 'attributes.yml'))
          if fresh_seed?(page, attrs_path)
            attrs = get_attributes(attrs_path)

            page.label        = attrs['label']
            page.layout       = site.layouts.find_by(:identifier => attrs['layout']) || parent.try(:layout)
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
        frags_to_clear = page.fragments.collect(&:identifier)
        fragments_attributes = [ ]
        file_extentions = %w(html haml jpg png gif)
        Dir.glob("#{path}/*.{#{file_extentions.join(',')}}").each do |block_path|
          extention = File.extname(block_path)[1..-1]
          identifier = block_path.split('/').last.gsub(/\.(#{file_extentions.join('|')})\z/, '')
          frags_to_clear.delete(identifier)
          if fresh_seed?(page, block_path)
            content = case extention
            when 'jpg', 'png', 'gif'
              ::File.open(block_path)
            when 'haml'
              Haml::Engine.new(::File.open(block_path).read).render.rstrip
            else
              ::File.open(block_path).read
            end

            fragments_attributes << {
              identifier: identifier,
              content:    content
            }
          end
        end

        # deleting removed fragments
        page.fragments.where(identifier: frags_to_clear).destroy_all

        page.fragments_attributes = fragments_attributes if fragments_attributes.present?

        # saving
        if page.changed? || page.fragments_attributes_changed || self.force_import
          if page.save
            save_categorizations!(page, categories)
            ComfortableMexicanSofa.logger.info("[FIXTURES] Imported Page \t #{page.full_path}")
          else
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import Page \n#{page.errors.inspect}")
          end
        end

        self.seed_ids << page.id

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
        self.site.pages.where('id NOT IN (?)', self.seed_ids).each{ |s| s.destroy }
      end
    end
  end

  class Exporter < ComfortableMexicanSofa::Seeds::Exporter
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
        page.fragments_attributes.each do |block|
          open(File.join(page_path, "#{block[:identifier]}.html"), 'w') do |f|
            f.write(block[:content])
          end
        end

        ComfortableMexicanSofa.logger.info("[FIXTURES] Exported Page \t #{page.full_path}")
      end
    end
  end
end
