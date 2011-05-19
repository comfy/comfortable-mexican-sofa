class Cms::Snippet < ActiveRecord::Base
  
  set_table_name :cms_snippets
  is_mirrored
  has_revisions_for :content
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
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
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
  end
  
  # Note: This might be slow. We have no idea where the snippet is used, so
  # gotta reload every single page. Kinda sucks, but might be ok unless there
  # are hundreds of pages.
  def clear_cached_page_content
    site.pages.all.each{ |page| page.save }
  end
  
end
