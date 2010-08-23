class CmsPageContent < ActiveRecord::Base
  
  belongs_to :cms_page
  
  # -- Class Methods --------------------------------------------------------
  def self.initialize_content_objects(content = '')
    raise tag_signature.to_s
  end
  
end
