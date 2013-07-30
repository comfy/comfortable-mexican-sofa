module ComfortableMexicanSofa::Fixture::Page
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    
    attr_accessor :target_pages

    def import!(path = self.path, parent = nil)
      Dir["#{path}*/"].each do |path|

        # Destroy all pages and start fresh
        page = site.pages.new

        # setting attributes
        categories    = []
        variations    = []
        page_contents = []

        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          attrs = get_attributes(attrs_path)

          page.label        = attrs['label']
          page.layout       = site.layouts.where(:identifier => attrs['layout']).first || parent.try(:layout)
          page.is_published = attrs['is_published'].nil?? true : attrs['is_published']
          page.position     = attrs['position'] if attrs['position']
          page.parent       = parent if parent.present?

          categories        = attrs['categories']
          variations        = attrs['variations'] || []

          if attrs['target_page']
            self.target_pages ||= {}
            self.target_pages[page] = attrs['target_page']
          end
        end

        variations.each do |variation_couple|
          # From the attributes.yml file, capture the variations and slug
          identifiers = variation_couple[0]
          slug        = variation_couple[1]

          # Prepare the :variation_identifiers hash that ActiveRecord expects
          variation_identifiers = Hash.new
          identifiers.each do |i|
            variation_identifiers[i.to_sym] = '1'
          end

          # Build a PageContent object
          pc = page.page_contents.build(
            :slug                  => slug,
            :variation_identifiers => variation_identifiers
          )

          # Loop through each content block and add it when the variations match
          blocks_attributes = []
          Dir.glob("#{path}/*.html").each do |block_path|
            # Derive the block variations and block_identifier from the filename
            filename           = block_path.split('/').last.gsub(/\.html$/, '')
            content_variations = filename[/\[.*?\]/].gsub(/\[|\]/, '').split(',')
            block_identifier   = filename[/.+\[/].gsub(/\[/, '')

            # If the block variations matches the variations defined within
            # the attributes.yml file, then we should add the block content
            if identifiers.sort == content_variations.sort
              blocks_attributes << {
                :identifier => block_identifier,
                :content    => File.open(block_path).read
              }
            end

          end

          # Assign our block_attributes array to the current PageContent object
          pc.blocks_attributes = blocks_attributes
        end

        if page.save
          save_categorizations!(page, categories)
          ComfortableMexicanSofa.logger.warn("[FIXTURES] Imported Page \t #{page.page_content.full_path}")
        else
          ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import Page \n#{page.errors.inspect}")
        end
        
        self.fixture_ids << page.id
        
        # importing child pages
        import!(path, page)
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
        page_path = File.join(path, page.ancestors.reverse.collect{|p| p.label.blank?? 'index' : p.label.parameterize}, page.label.parameterize)
        FileUtils.mkdir_p(page_path)
        # variations = page.page_contents.collect {|pc| puts pc.variation_identifiers.inspect}
        open(File.join(page_path, 'attributes.yml'), 'w') do |f|
          f.write({
            'label'         => page.label,
            'layout'        => page.layout.try(:identifier),
            'parent'        => page.parent && (page.parent.slug.present? ? page.parent.slug : 'index'),
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