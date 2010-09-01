class CmsLayout < ActiveRecord::Base
  
  acts_as_tree
  
  # -- Relationships --------------------------------------------------------
  has_many :cms_pages, :dependent => :nullify
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true
  validates :content,
    :presence   => true
    
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for layouts
  def self.options_for_select(cms_layout = nil, current_layout = nil, depth = 0, spacer = '. . ')
    out = []
    [current_layout || CmsLayout.roots].flatten.each do |layout|
      next if cms_layout == layout
      out << [ "#{spacer*depth}#{layout.label}", layout.id ]
      layout.children.each do |child|
        out += options_for_select(cms_layout, child, depth + 1, spacer)
      end
    end
    return out.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is <cms:page:content> If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored
  def content
    if parent
      c = parent.content.gsub CmsTag::PageText.regex_tag_signature('content'), read_attribute(:content)
      c == parent.content ? read_attribute(:content) : c
    else
      read_attribute(:content)
    end
  end
  
end
