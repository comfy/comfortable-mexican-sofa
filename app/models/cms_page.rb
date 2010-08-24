class CmsPage < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_blocks, :dependent => :destroy
  
  # -- Instance Methods -----------------------------------------------------
  def content
    content = cms_layout.content.dup
    cms_blocks.each do |block|
      content.gsub!(block.regex_tag_signature, block.render.to_s)
    end
    content
  end
  
end
