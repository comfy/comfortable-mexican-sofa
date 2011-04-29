module ComfortableMexicanSofa::Fixtures
  
  def self.sync
    
  end
  
  def self.sync_layouts(site)
    return unless path = find_path(site, 'layouts')
    
    
  end
  
  def self.sync_pages
    
  end
  
  def self.sync_snippets(site)
    return unless path = find_path(site, 'snippets')
    
    snippet_ids = []
    Dir.glob("#{path}/*").select{|s| File.directory?(s)}.each do |path|
      slug = path.split('/').last
      snippet = site.snippets.find_by_slug(slug) || site.snippets.new(:slug => slug)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          snippet_attributes = YAML.load_file(file_path).symbolize_keys!
          snippet.label = snippet_attributes[:label] || slug.titleize
        end
      elsif snippet.new_record?
        snippet.label = slug.titleize
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, "content.html"))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          snippet.content = File.open(file_path, 'rb').read
        end
      end
      
      # saving
      snippet.save! if snippet.changed?
      snippet_ids << snippet.id
    end
    
    # removing all db entries that are not in fixtures
    Cms::Snippet.where('id NOT IN (?)', snippet_ids).each{ |s| s.destroy }
  end
  
  def self.find_path(site, dir)
    path = nil
    File.exists?(path = File.join(ComfortableMexicanSofa.config.fixtures_path, site.hostname, dir)) ||
    !ComfortableMexicanSofa.config.enable_multiple_sites &&
    File.exists?(path = File.join(ComfortableMexicanSofa.config.fixtures_path, dir))
    return path
  end
  
end