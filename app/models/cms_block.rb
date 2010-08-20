class CmsBlock < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------

  belongs_to :cms_page
  
  # -- Validations ----------------------------------------------------------

  validates :label,
    :presence => true,
    :uniqueness => { :scope => :cms_page_id }
  
  # -- Scopes ---------------------------------------------------------------

  scope :with_label, lambda{ |name|{
    :conditions => {:label => name}
  }}
  
end
