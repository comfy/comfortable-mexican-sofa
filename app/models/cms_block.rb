class CmsBlock < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => true
  
  # -- Class Methods --------------------------------------------------------
  def self.initialize_subclass_content_blocks(content = '')
    # todo
  end
  
  # method called by the subclasses 
  def self.initialize_content_blocks(content = '')
    content.scan(regex_tag_signature).flatten.collect do |label|
      # todo, grab from db if exist
      self.new(:label => label)
    end
  end
  
end
