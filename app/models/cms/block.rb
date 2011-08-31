class Cms::Block < ActiveRecord::Base
  
  if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
    establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
  end
  
  set_table_name :cms_blocks
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
  
end
