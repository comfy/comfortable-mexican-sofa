class Cms::Block < ActiveRecord::Base
  establish_connection "#{ComfortableMexicanSofa.config.database_prefix}#{Rails.env}"
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
  
end
