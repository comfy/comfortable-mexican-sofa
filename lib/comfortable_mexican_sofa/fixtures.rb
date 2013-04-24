module ComfortableMexicanSofa::Fixtures
  
  def self.import_all(to_site, from_folder = nil, force_import = false)
    import_layouts  to_site, from_folder, nil, true, nil, [], force_import
    import_pages    to_site, from_folder, nil, true, nil, [], force_import
    import_snippets to_site, from_folder, force_import
  end
  
  def self.export_all(from_site, to_folder = nil)
    export_layouts  from_site, to_folder
    export_pages    from_site, to_folder
    export_snippets from_site, to_folder
  end
  
  def self.import_layouts(to_site, from_folder = nil, path = nil, root = true, parent = nil, layout_ids = [], force_import = false)
    site = Cms::Site.find_or_create_by_identifier(to_site)
    unless path ||= find_fixtures_path((from_folder || to_site), 'layouts')
      ComfortableMexicanSofa.logger.warn('Cannot find Layout fixtures')
      return []
    end
    
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      identifier = path.split('/').last
      layout = site.layouts.find_by_identifier(identifier) || site.layouts.new(:identifier => identifier)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{identifier}.yml"))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at || force_import
          attributes = YAML.load_file(file_path).try(:symbolize_keys!) || { }
          layout.label      = attributes[:label] || identifier.titleize
          layout.app_layout = attributes[:app_layout] || parent.try(:app_layout)
          layout.position   = attributes[:position] if attributes[:position]
        end
      elsif layout.new_record?
        layout.label      = identifier.titleize
        layout.app_layout = parent.try(:app_layout) 
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at || force_import
          layout.content = File.open(file_path).read
        end
      end
      if File.exists?(file_path = File.join(path, 'css.css'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at || force_import
          layout.css = File.open(file_path).read
        end
      end
      if File.exists?(file_path = File.join(path, 'js.js'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at || force_import
          layout.js = File.open(file_path).read
        end
      end
      
      # saving
      layout.parent = parent
      if layout.changed?
        if layout.save
          ComfortableMexicanSofa.logger.warn("[Fixtures] Saved Layout {#{layout.identifier}}")
        else
          ComfortableMexicanSofa.logger.error("[Fixtures] Failed to save Layout {#{layout.errors.inspect}}")
          next
        end
      end
      layout_ids << layout.id
      
      # checking for nested fixtures
      layout_ids += import_layouts(to_site, from_folder, path, false, layout, layout_ids)
    end
    
    # removing all db entries that are not in fixtures
    if root
      site.layouts.where('id NOT IN (?)', layout_ids.uniq).each{ |l| l.destroy } 
      ComfortableMexicanSofa.logger.warn('Imported Layouts!')
    end
    
    # returning ids of layouts in fixtures
    layout_ids.uniq
  end
  
  def self.import_pages(to_site, from_folder = nil, path = nil, root = true, parent = nil, page_ids = [], force_import = false)
    site = Cms::Site.find_or_create_by_identifier(to_site)
    unless path ||= find_fixtures_path((from_folder || to_site), 'pages')
      ComfortableMexicanSofa.logger.warn('Cannot find Page fixtures')
      return []
    end
    
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      page = if parent
        parent.children.find_by_slug(slug) || site.pages.new(:parent => parent, :slug => slug)
      else
        site.pages.root || site.pages.new(:slug => slug)
      end
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if page.new_record? || File.mtime(file_path) > page.updated_at || force_import
          attributes = YAML.load_file(file_path).try(:symbolize_keys!) || { }
          page.label = attributes[:label] || slug.titleize
          page.layout = site.layouts.find_by_identifier(attributes[:layout]) || parent.try(:layout)
          page.target_page = site.pages.find_by_full_path(attributes[:target_page])
          page.is_published = attributes[:is_published].nil?? true : attributes[:is_published]
          page.position = attributes[:position] if attributes[:position]
        end
      elsif page.new_record?
        page.label = slug.titleize
        page.layout = parent.try(:layout)
      end
      
      # updating content
      blocks_to_clear = page.blocks.collect(&:identifier)
      blocks_attributes = [ ]
      Dir.glob("#{path}/*.html").each do |file_path|
        identifier = file_path.split('/').last.gsub(/\.html$/, '')
        blocks_to_clear.delete(identifier)
        if page.new_record? || File.mtime(file_path) > page.updated_at || force_import
          blocks_attributes << {
            :identifier => identifier,
            :content    => File.open(file_path).read
          }
        end
      end
      
      # clearing removed blocks
      blocks_to_clear.each do |identifier|
        blocks_attributes << {
          :identifier => identifier,
          :content    => nil
        }
      end
      
      # saving
      page.blocks_attributes = blocks_attributes if blocks_attributes.present?
      if page.changed? || blocks_attributes.present?
        if page.save
          ComfortableMexicanSofa.logger.warn("[Fixtures] Saved Page {#{page.full_path}}")
        else
          ComfortableMexicanSofa.logger.warn("[Fixtures] Failed to save Page {#{page.errors.inspect}}")
          next
        end
      end
      page_ids << page.id
      
      # checking for nested fixtures
      page_ids += import_pages(to_site, from_folder, path, false, page, page_ids)
    end
    
    # removing all db entries that are not in fixtures
    if root
      site.pages.where('id NOT IN (?)', page_ids.uniq).each{ |p| p.destroy }
      ComfortableMexicanSofa.logger.warn('Imported Pages!')
    end
    
    # returning ids of layouts in fixtures
    page_ids.uniq
  end
  
  def self.import_snippets(to_site, from_folder = nil, force_import = false)
    site = Cms::Site.find_or_create_by_identifier(to_site)
    unless path = find_fixtures_path((from_folder || to_site), 'snippets')
      ComfortableMexicanSofa.logger.warn('Cannot find Snippet fixtures')
      return []
    end
    
    snippet_ids = []
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      identifier = path.split('/').last
      snippet = site.snippets.find_by_identifier(identifier) || site.snippets.new(:identifier => identifier)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{identifier}.yml"))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at || force_import
          attributes = YAML.load_file(file_path).try(:symbolize_keys!) || { }
          snippet.label = attributes[:label] || identifier.titleize
        end
      elsif snippet.new_record?
        snippet.label = identifier.titleize
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at || force_import
          snippet.content = File.open(file_path).read
        end
      end
      
      # saving
      if snippet.changed?
        if snippet.save
          ComfortableMexicanSofa.logger.warn("[Fixtures] Saved Snippet {#{snippet.identifier}}")
        else
          ComfortableMexicanSofa.logger.warn("[Fixtures] Failed to save Snippet {#{snippet.errors.inspect}}")
          next
        end
      end
      snippet_ids << snippet.id
    end
    
    # removing all db entries that are not in fixtures
    site.snippets.where('id NOT IN (?)', snippet_ids).each{ |s| s.destroy }
    ComfortableMexicanSofa.logger.warn('Imported Snippets!')
  end
  
  def self.export_layouts(from_site, to_folder = nil)
    return unless site = Cms::Site.find_by_identifier(from_site)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_folder || site.identifier), 'layouts')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.layouts.each do |layout|
      layout_path = File.join(path, layout.ancestors.reverse.collect{|l| l.identifier}, layout.identifier)
      FileUtils.mkdir_p(layout_path)
      
      open(File.join(layout_path, "_#{layout.identifier}.yml"), 'w') do |f|
        f.write({
          'label'       => layout.label,
          'app_layout'  => layout.app_layout,
          'parent'      => layout.parent.try(:identifier),
          'position'    => layout.position
        }.to_yaml)
      end
      open(File.join(layout_path, 'content.html'), 'w') do |f|
        f.write(layout.content)
      end
      open(File.join(layout_path, 'css.css'), 'w') do |f|
        f.write(layout.css)
      end
      open(File.join(layout_path, 'js.js'), 'w') do |f|
        f.write(layout.js)
      end
    end
  end
  
  def self.export_pages(from_site, to_folder = nil)
    return unless site = Cms::Site.find_by_identifier(from_site)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_folder || site.identifier), 'pages')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.pages.each do |page|
      page.slug = 'index' if page.slug.blank?
      page_path = File.join(path, page.ancestors.reverse.collect{|p| p.slug.blank?? 'index' : p.slug}, page.slug)
      FileUtils.mkdir_p(page_path)
      
      open(File.join(page_path, "_#{page.slug}.yml"), 'w') do |f|
        f.write({
          'label'         => page.label,
          'layout'        => page.layout.try(:identifier),
          'parent'        => page.parent && (page.parent.slug.present?? page.parent.slug : 'index'),
          'target_page'   => page.target_page.try(:slug),
          'is_published'  => page.is_published,
          'position'      => page.position
        }.to_yaml)
      end
      page.blocks_attributes.each do |block|
        open(File.join(page_path, "#{block[:identifier]}.html"), 'w') do |f|
          f.write(block[:content])
        end
      end
    end
  end
  
  def self.export_snippets(from_site, to_folder = nil)
    return unless site = Cms::Site.find_by_identifier(from_site)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_folder || site.identifier), 'snippets')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.snippets.each do |snippet|
      FileUtils.mkdir_p(snippet_path = File.join(path, snippet.identifier))
      open(File.join(snippet_path, "_#{snippet.identifier}.yml"), 'w') do |f|
        f.write({'label' => snippet.label}.to_yaml)
      end
      open(File.join(snippet_path, 'content.html'), 'w') do |f|
        f.write(snippet.content)
      end
    end
  end
  
protected
  
  def self.find_fixtures_path(identifier, dir)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, identifier, dir)
    File.exists?(path) ? path : nil
  end
  
end
