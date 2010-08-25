class CmsPage < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_blocks, :dependent => :destroy
  
  # -- Instance Methods -----------------------------------------------------
  def render_content
    content = cms_layout.content.dup
    CmsTag.initialize_tags(content, :cms_page => self).each do |tag|
      content.gsub!(tag.regex_tag_signature){ tag.render }
    end
    return content
  end
  
end
