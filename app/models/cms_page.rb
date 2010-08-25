class CmsPage < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_blocks, :dependent => :destroy
  
  # -- Instance Methods -----------------------------------------------------
  def content
   # 
  end
  
  # Initilizing tags based on layout content. If not found in the database,
  # blank ones will be initilized.
  def initialize_tags
    content = cms_layout.content.dup
    raise CmsTag.tag_classes.inspect
  end
  
end
