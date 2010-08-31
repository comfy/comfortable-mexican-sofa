class CmsPage < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_blocks, :dependent => :destroy
  accepts_nested_attributes_for :cms_blocks
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence => true
  validates :slug,
    :presence => true,
    :format   => /^\w[a-z0-9_-]*$/i
  validates :cms_layout,
    :presence => true
  
  # -- Instance Methods -----------------------------------------------------
  def render_content
    content = cms_layout.content.dup
    initialize_tags.each do |tag|
      content.gsub!(tag.regex_tag_signature){ tag.render }
    end
    return content
  end
  
  # Returns an array of tag objects, at the same time populates #cms_blocks
  # of the current page
  def initialize_tags
    CmsTag.initialize_tags(self)
  end
  
end
