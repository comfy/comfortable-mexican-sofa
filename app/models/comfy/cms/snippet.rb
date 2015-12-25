class Comfy::Cms::Snippet < ActiveRecord::Base
  self.table_name = 'comfy_cms_snippets'
  
  cms_is_categorized
  cms_is_mirrored
  cms_has_revisions_for :content
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  
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
  default_scope -> { order('comfy_cms_snippets.position') }
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.identifier.try(:titleize) : self.label
  end
  
  def clear_page_content_cache
    Comfy::Cms::Page.where(:id => site.pages.pluck(:id)).update_all(:content_cache => nil)
  end
  
  def assign_position
    max = self.site.snippets.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
end
