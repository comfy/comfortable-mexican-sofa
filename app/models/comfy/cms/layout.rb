# encoding: utf-8

class Comfy::Cms::Layout < ActiveRecord::Base
  self.table_name = 'comfy_cms_layouts'
  
  cms_acts_as_tree
  cms_is_mirrored
  cms_has_revisions_for :content, :css, :js
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  has_many :pages, :dependent => :nullify
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  before_create :assign_position
  after_save    :clear_page_content_cache
  after_destroy :clear_page_content_cache
  
  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :identifier,
    :presence   => true,
    :uniqueness => { :scope => :site_id },
    :format     => { :with => /\A\w[a-z0-9_-]*\z/i }
    
  # -- Scopes ---------------------------------------------------------------
  default_scope -> { order('comfy_cms_layouts.position') }
  
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
  def self.app_layouts_for_select(view_paths)
    view_paths.map(&:to_s).select { |path| path.start_with?(Rails.root.to_s) }.flat_map do |full_path|
      Dir.glob("#{full_path}/layouts/**/*.html.*").collect do |filename|
        filename.gsub!("#{full_path}/layouts/", '')
        filename.split('/').last[0...1] == '_' ? nil : filename.split('.').first
      end.compact.sort
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
        content.to_s
      end
    else
      content.to_s
    end
  end

  def cache_buster
    updated_at.to_i
  end
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.identifier.try(:titleize) : self.label
  end
  
  def assign_position
    return if self.position.to_i > 0
    max = self.site.layouts.where(:parent_id => self.parent_id).maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
  # Forcing page content reload
  def clear_page_content_cache
    Comfy::Cms::Page.where(:id => self.pages.pluck(:id)).update_all(:content_cache => nil)
    self.children.each{ |child_layout| child_layout.clear_page_content_cache }
  end
  
end
