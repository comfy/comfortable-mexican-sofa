module ComfortableMexicanSofa::Fixtures
  
  def self.import_all(to_hostname, from_hostname = nil)
    import_layouts  to_hostname, from_hostname
    import_pages    to_hostname, from_hostname
    import_snippets to_hostname, from_hostname
  end
  
  def self.export_all(from_hostname, to_hostname = nil)
    export_layouts  from_hostname, to_hostname
    export_pages    from_hostname, to_hostname
    export_snippets from_hostname, to_hostname
  end
  
  def self.import_layouts(to_hostname, from_hostname = nil, path = nil, root = true, parent = nil, layout_ids = [])
    return unless site = Cms::Site.find_by_hostname(to_hostname)
    return unless path ||= find_fixtures_path((from_hostname || to_hostname), 'layouts')
    
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      layout = site.layouts.find_by_slug(slug) || site.layouts.new(:slug => slug)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          attributes = YAML.load_file(file_path).symbolize_keys!
          layout.label      = attributes[:label] || slug.titleize
          layout.app_layout = attributes[:app_layout] || parent.try(:app_layout) 
        end
      elsif layout.new_record?
        layout.label      = slug.titleize
        layout.app_layout = parent.try(:app_layout) 
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.content = File.open(file_path, 'rb').read
        end
      end
      if File.exists?(file_path = File.join(path, 'css.css'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.css = File.open(file_path, 'rb').read
        end
      end
      if File.exists?(file_path = File.join(path, 'js.js'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.js = File.open(file_path, 'rb').read
        end
      end
      
      # saving
      layout.parent = parent
      if layout.changed?
        layout.save!
        Rails.logger.debug "[Fixtures] Saved Layout {#{layout.slug}}"
      end
      layout_ids << layout.id
      
      # checking for nested fixtures
      layout_ids += import_layouts(to_hostname, from_hostname, path, false, layout, layout_ids)
    end
    
    # removing all db entries that are not in fixtures
    site.layouts.where('id NOT IN (?)', layout_ids.uniq).each{ |l| l.destroy } if root
    
    # returning ids of layouts in fixtures
    layout_ids
  end
  
  def self.import_pages(to_hostname, from_hostname = nil, path = nil, root = true, parent = nil, page_ids = [])
    return unless site = Cms::Site.find_by_hostname(to_hostname)
    return unless path ||= find_fixtures_path((from_hostname || to_hostname), 'pages')
    
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      page = if parent
        parent.children.find_by_slug(slug) || parent.children.new(:slug => slug, :site => site)
      else
        site.pages.root || site.pages.new(:slug => slug)
      end
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if page.new_record? || File.mtime(file_path) > page.updated_at
          attributes = YAML.load_file(file_path).symbolize_keys!
          page.label = attributes[:label] || slug.titleize
          page.layout = site.layouts.find_by_slug(attributes[:layout]) || parent.try(:layout)
          page.target_page = site.pages.find_by_full_path(attributes[:target_page])
          page.is_published = attributes[:is_published].present?? attributes[:is_published] : true
        end
      elsif page.new_record?
        page.label = slug.titleize
        page.layout = parent.try(:layout)
      end
      
      # updating content
      blocks_attributes = [ ]
      Dir.glob("#{path}/*.html").each do |file_path|
        if page.new_record? || File.mtime(file_path) > page.updated_at
          label = file_path.split('/').last.split('.').first
          blocks_attributes << {
            :label    => label,
            :content  => File.open(file_path, 'rb').read
          }
        end
      end
      
      # saving
      page.blocks_attributes = blocks_attributes if blocks_attributes.present?
      if page.changed? || blocks_attributes.present?
        page.save! 
        Rails.logger.debug "[Fixtures] Saved Page {#{page.full_path}}"
      end
      page_ids << page.id
      
      # checking for nested fixtures
      page_ids += import_pages(to_hostname, from_hostname, path, false, page, page_ids)
    end
    
    # removing all db entries that are not in fixtures
    site.pages.where('id NOT IN (?)', page_ids.uniq).each{ |p| p.destroy } if root
    
    # returning ids of layouts in fixtures
    page_ids
  end
  
  def self.import_snippets(to_hostname, from_hostname = nil)
    return unless site = Cms::Site.find_by_hostname(to_hostname)
    return unless path = find_fixtures_path((from_hostname || to_hostname), 'snippets')
    
    snippet_ids = []
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      snippet = site.snippets.find_by_slug(slug) || site.snippets.new(:slug => slug)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          attributes = YAML.load_file(file_path).symbolize_keys!
          snippet.label = attributes[:label] || slug.titleize
        end
      elsif snippet.new_record?
        snippet.label = slug.titleize
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          snippet.content = File.open(file_path, 'rb').read
        end
      end
      
      # saving
      if snippet.changed?
        snippet.save!
        Rails.logger.debug "[Fixtures] Saved Snippet {#{snippet.slug}}"
      end
      snippet_ids << snippet.id
    end
    
    # removing all db entries that are not in fixtures
    site.snippets.where('id NOT IN (?)', snippet_ids).each{ |s| s.destroy }
  end
  
  def self.export_layouts(from_hostname, to_hostname = nil)
    return unless site = Cms::Site.find_by_hostname(from_hostname)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_hostname || site.hostname), 'layouts')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.layouts.each do |layout|
      layout_path = File.join(path, layout.ancestors.reverse.collect{|l| l.slug}, layout.slug)
      FileUtils.mkdir_p(layout_path)
      
      open(File.join(layout_path, "_#{layout.slug}.yml"), 'w') do |f|
        f.write({
          'label'       => layout.label,
          'app_layout'  => layout.app_layout,
          'parent'      => layout.parent.try(:slug)
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
  
  def self.export_pages(from_hostname, to_hostname = nil)
    return unless site = Cms::Site.find_by_hostname(from_hostname)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_hostname || site.hostname), 'pages')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.pages.each do |page|
      page.slug = 'index' if page.slug.blank?
      page_path = File.join(path, page.ancestors.reverse.collect{|p| p.slug.blank?? 'index' : p.slug}, page.slug)
      FileUtils.mkdir_p(page_path)
      
      open(File.join(page_path, "_#{page.slug}.yml"), 'w') do |f|
        f.write({
          'label'         => page.label,
          'layout'        => page.layout.try(:slug),
          'parent'        => page.parent && (page.parent.slug.present?? page.parent.slug : 'index'),
          'target_page'   => page.target_page.try(:slug),
          'is_published'  => page.is_published
        }.to_yaml)
      end
      page.blocks_attributes.each do |block|
        open(File.join(page_path, "#{block[:label]}.html"), 'w') do |f|
          f.write(block[:content])
        end
      end
    end
  end
  
  def self.export_snippets(from_hostname, to_hostname = nil)
    return unless site = Cms::Site.find_by_hostname(from_hostname)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, (to_hostname || site.hostname), 'snippets')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    
    site.snippets.each do |snippet|
      FileUtils.mkdir_p(snippet_path = File.join(path, snippet.slug))
      open(File.join(snippet_path, "_#{snippet.slug}.yml"), 'w') do |f|
        f.write({'label' => snippet.label}.to_yaml)
      end
      open(File.join(snippet_path, 'content.html'), 'w') do |f|
        f.write(snippet.content)
      end
    end
  end
  
protected
  
  def self.find_fixtures_path(hostname, dir)
    path = File.join(ComfortableMexicanSofa.config.fixtures_path, hostname, dir)
    File.exists?(path) ? path : nil
  end
  
end