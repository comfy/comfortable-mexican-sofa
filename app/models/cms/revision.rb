class Cms::Revision < ActiveRecord::Base
  establish_connection "#{ComfortableMexicanSofa.config.database_prefix}#{Rails.env}"
  
  set_table_name :cms_revisions
  
  serialize :data
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order('created_at DESC')
  
end