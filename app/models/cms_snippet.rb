class CmsSnippet < ActiveRecord::Base
    
  # -- Validations ----------------------------------------------------------
  
  validates :label,
    :presence => true,
    :uniqueness => true,
    :format => { :with => /^\w[a-z0-9_-]*$/i }
  
  # -- Class Methods --------------------------------------------------------
  
  def self.content_for(label)
    (s = find_by_label(label)) ? s.content : ''
  end
  
  # -- Scopes ---------------------------------------------------------------
  
  default_scope :order => 'label'
    
end
