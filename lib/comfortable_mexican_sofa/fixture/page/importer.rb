module ComfortableMexicanSofa::Fixture::Page
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    attr_accessor :target_pages

    def import!(path = self.path)
      Dir["#{path}*/"].each do |child_path|
        import_only! child_path, recursive: true, relative_path: false
      end
      clean_up
    end

    def import_only! path, params={}
      params = {
        relative_path: true,
        parent: nil,
        recursive: false
      }.merge params

      path = File.join self.path, path if params[:relative_path]

      slug = path.split('/').last

      parent = params[:parent]
      page = if parent
               parent.children.where(:slug => slug).first ||
                 site.pages.new(:parent => parent, :slug => slug)
             else
               site.pages.root || site.pages.new(:slug => slug)
             end

      # setting attributes
      categories = import_attrbutes! page, path
      # setting content
      import_content! page, path

      # saving
      if page.changed? || page.blocks_attributes_changed || self.force_import
        if page.save
          save_categorizations!(page, categories)
          ComfortableMexicanSofa.logger.warn(
            "[FIXTURES] Imported Page \t #{page.full_path}")
        else
          ComfortableMexicanSofa.logger.warn(
            "[FIXTURES] Failed to import Page \n#{page.errors.inspect}")
        end
      end

      self.fixture_ids << page.id

      if params[:recursive]
        Dir["#{path}*/"].each do |child_path|
          import_only!(child_path,
                       parent: page,
                       recursive: true,
                       relative_path: false)
        end
      end

      # link up targets if this is the root page, all pages will be done
      # importing at this point so they can be looked up
      link_targets if parent.nil? && self.target_pages.present?

      page
    end

    private
    def import_content! page, path
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

    end

    def import_attrbutes! page, path
      categories = []

      if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
        if fresh_fixture?(page, attrs_path)
          attrs = get_attributes(attrs_path)

          page.label = attrs['label']

          first_layout = site.layouts.where(:identifier => attrs['layout']).first
          page.layout = first_layout || parent.try(:layout)

          page.is_published = attrs['is_published'].nil?? true : attrs['is_published']
          page.position = attrs['position'] if attrs['position']

          categories = attrs['categories']

          if attrs['target_page']
            self.target_pages ||= {}
            self.target_pages[page] = attrs['target_page']
          end
        end
      end
      categories
    end

    def link_targets
      self.target_pages.each do |page, target|
        if target_page = self.site.pages.where(:full_path => target).first
          page.target_page = target_page
          page.save
        end
      end
    end

    def clean_up
      self.site.pages.where('id NOT IN (?)', self.fixture_ids).each{ |s| s.destroy }
    end
  end
end
