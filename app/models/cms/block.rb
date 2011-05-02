class Cms::Block < ActiveRecord::Base
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
  
end
