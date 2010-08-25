class CmsPage < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_blocks, :dependent => :destroy
  
  # -- Instance Methods -----------------------------------------------------
  def render_content
    CmsTag.initialize_tags(layout_content, :cms_page => self).each do |tag|
      layout_content.gsub!(tag.regex_tag_signature){ tag.render }
    end
    return layout_content
  end
  
protected
  
  def layout_content
    @layout_content ||= cms_layout.content.dup
  end
  
end
