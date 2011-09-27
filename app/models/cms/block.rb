class Cms::Block < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  before_save :save_file
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
    
  def save_file
    p '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
    p self.content
    p self.content.class.name
  end
  
end
