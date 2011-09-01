class Cms::Block < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
  
end
