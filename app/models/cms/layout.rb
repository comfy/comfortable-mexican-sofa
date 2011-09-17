class Cms::Layout < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
    
  set_table_name :cms_layouts
  
  cms_acts_as_tree
  cms_is_mirrored
  cms_has_revisions_for :content, :css, :js
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  has_many :pages, :dependent => :nullify
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  before_validation :assign_position,
                    :on => :create
  after_save    :clear_cached_page_content
  after_destroy :clear_cached_page_content
  
  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
    
  # -- Scopes ---------------------------------------------------------------
  default_scope order(:position)
  
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for layouts
  def self.options_for_select(site, layout = nil, current_layout = nil, depth = 0, spacer = '. . ')
    out = []
    [current_layout || site.layouts.roots].flatten.each do |l|
      next if layout == l
      out << [ "#{spacer*depth}#{l.label}", l.id ]
      l.children.each do |child|
        out += options_for_select(site, layout, child, depth + 1, spacer)
      end
    end
    return out.compact
  end
  
  # List of available application layouts
  def self.app_layouts_for_select
    Dir.glob(File.expand_path('app/views/layouts/**/*.html.*', Rails.root)).collect do |filename|
      filename.gsub!("#{File.expand_path('app/views/layouts', Rails.root)}/", '')
      filename.split('/').last[0...1] == '_' ? nil : filename
    end.compact.sort
  end
  
  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is {cms:page:content} If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored.
  def merged_content
    if parent
      regex = /\{\{\s*cms:page:content:?(?:(?::text)|(?::rich_text))?\s*\}\}/
      if parent.merged_content.match(regex)
        parent.merged_content.gsub(regex, content.to_s)
      else
        content
      end
    else
      content
    end
  end
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
  end
  
  def assign_position
    max = Cms::Layout.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
  # Forcing page content reload
  def clear_cached_page_content
    self.pages.each{ |page| page.save! }
    self.children.each{ |child_layout| child_layout.clear_cached_page_content }
  end
  
end
