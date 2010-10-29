class CmsLayout < ActiveRecord::Base
  
  acts_as_tree
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  has_many :cms_pages, :dependent => :nullify
  
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
    
  validate :content_tag_presence
    
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
  
  # Attempting to initialize layout object from yaml file that is found in config.seed_data_path
  def self.load_from_file(site, name)
    return nil if ComfortableMexicanSofa.config.seed_data_path.blank?
    file_path = "#{ComfortableMexicanSofa.config.seed_data_path}/#{site.hostname}/layouts/#{name}.yml"
    return nil unless File.exists?(file_path)
    attributes            = YAML.load_file(file_path).symbolize_keys!
    attributes[:parent]   = CmsLayout.load_from_file(site, attributes[:parent])
    attributes[:cms_site] = site
    new(attributes)
  end
  
  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is {cms:page:content} If parent layout has this tag
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
    self.parent ? [self.parent.merged_css, self.css].join("\n") : self.css.to_s
  end
  
  def merged_js
    self.parent ? [self.parent.merged_js, self.js].join("\n") : self.js.to_s
  end
  
protected
  
  def content_tag_presence
    CmsTag.process_content((test_page = CmsPage.new), content)
    if test_page.cms_tags.select{|t| t.class.superclass == CmsBlock}.blank?
      self.errors.add(:content, 'No cms page tags defined')
    end
  end
  
end
