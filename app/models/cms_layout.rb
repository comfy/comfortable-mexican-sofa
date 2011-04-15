class CmsLayout < ActiveRecord::Base
  
  acts_as_tree
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  has_many :cms_pages, :dependent => :nullify
  
  # -- Callbacks ------------------------------------------------------------
  after_save    :clear_cache, :clear_cached_page_content
  after_destroy :clear_cache, :clear_cached_page_content
  
  # -- Validations ----------------------------------------------------------
  validates :cms_site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :cms_site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
  validates :content,
    :presence   => true
  validate :check_content_tag_presence
    
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for layouts
  def self.options_for_select(cms_site, cms_layout = nil, current_layout = nil, depth = 0, spacer = '. . ')
    out = []
    [current_layout || cms_site.cms_layouts.roots].flatten.each do |layout|
      next if cms_layout == layout
      out << [ "#{spacer*depth}#{layout.label}", layout.id ]
      layout.children.each do |child|
        out += options_for_select(cms_site, cms_layout, child, depth + 1, spacer)
      end
    end
    return out.compact
  end
  
  # List of available application layouts
  def self.app_layouts_for_select
    Dir.glob(File.expand_path('app/views/layouts/*.html.*', Rails.root)).collect do |filename|
      match = filename.match(/\w*.html.\w*$/)
      app_layout = match && match[0]
      app_layout.to_s[0...1] == '_' ? nil : app_layout
    end.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is {cms:page:content} If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored.
  def merged_content
    if parent
      regex = /\{\{\s*cms:page:content:?(?:(?::text)|(?::rich_text))?\s*\}\}/
      if parent.merged_content.match(regex)
        parent.merged_content.gsub(regex, content)
      else
        content
      end
    else
      content
    end
  end
  
protected
  
  def check_content_tag_presence
    CmsTag.process_content((test_page = cms_site.cms_pages.new), content)
    if test_page.cms_tags.select{|t| t.class.superclass == CmsBlock}.blank?
      self.errors.add(:content, 'No cms page tags defined')
    end
  end
  
  # After saving need to make sure that cached pages for css and js for this
  # layout and its children are gone. Good enough to avoid using cache sweepers.
  def clear_cache
    FileUtils.rm File.expand_path("cms-css/#{self.slug}.css", Rails.public_path), :force => true
    FileUtils.rm File.expand_path("cms-js/#{self.slug}.js",   Rails.public_path), :force => true
  end
  
  # Forcing page content reload
  def clear_cached_page_content
    self.cms_pages.each{ |page| page.save! }
    self.children.each{ |child_layout| child_layout.save! }
  end
  
end
