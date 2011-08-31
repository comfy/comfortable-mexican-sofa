class Cms::Revision < ActiveRecord::Base
  
  if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
    establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
  end
  
  set_table_name :cms_revisions
  
  serialize :data
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order('created_at DESC')
  
end