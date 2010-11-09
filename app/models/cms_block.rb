class CmsBlock < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :cms_page_id }
  
  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(cms_page, label)
    if block = cms_page.cms_blocks.detect{ |b| b.label == label.to_s }
      self.new(
        :record_id  => block.id,
        :cms_page   => cms_page,
        :label      => block.label,
        :content    => block.content
      )
    else
      self.new(
        :label    => label.to_s,
        :cms_page => cms_page
      )
    end
  end
  
end
