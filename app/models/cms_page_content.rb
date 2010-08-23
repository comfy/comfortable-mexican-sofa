class CmsPageContent < ActiveRecord::Base
  
  belongs_to :cms_page
  
  # -- Class Methods --------------------------------------------------------
  # method called by the subclasses 
  def self.initialize_content_objects(content = '')
    content.scan(regex_tag_signature).flatten.collect do |label|
      self.new(:label => label)
    end
  end
  
end
