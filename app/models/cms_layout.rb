class CmsLayout < ActiveRecord::Base
  
  acts_as_tree
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  has_many :cms_pages, :dependent => :nullify
  
  # -- Validations ----------------------------------------------------------
  validates :cms_site_id, :presence => true
  validates :label,       :presence => true
  validates :content,     :presence => true
    
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
      match && match[0]
    end.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is <cms:page:content> If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored.
  def merged_content
    if parent
      c = parent.merged_content.gsub CmsTag::PageText.regex_tag_signature('content'), content
      c == parent.merged_content ? content : c
    else
      content
    end
  end
  
  def merged_css
    self.parent ? self.parent.merged_css + self.css : self.css.to_s
  end
  
  def merged_js
    self.parent ? self.parent.merged_js + self.js : self.js.to_s
  end
end
