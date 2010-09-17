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
  
  def self.initialize_or_find(cms_page, label)
    find_by_label(label) || new(:label => label)
  end

end
