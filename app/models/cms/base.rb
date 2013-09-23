class Cms::Base < ActiveRecord::Base

  self.abstract_class = true
  
  # Establishing database connection if custom one is defined
  if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
    establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
  end
  
  def self.table_name_prefix
    'cms_'
  end
  
end