class Cms::Block < ActiveRecord::Base
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
  
  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(page, label)
    if block = page.blocks.detect{ |b| b.label == label.to_s }
      self.new(
        :record_id  => block.id,
        :page       => page,
        :label      => block.label,
        :content    => block.content
      )
    else
      self.new(
        :label  => label.to_s,
        :page   => page
      )
    end
  end
  
end
