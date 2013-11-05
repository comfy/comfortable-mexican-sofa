module ComfortableMexicanSofa::Fixture::Page
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
