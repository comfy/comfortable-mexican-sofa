class Cms::Revision < ActiveRecord::Base
  unless Rails.env == 'test'
    establish_connection "#{ComfortableMexicanSofa.config.database_prefix}#{Rails.env}"
  end
    
  set_table_name :cms_revisions
  
  serialize :data
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order('created_at DESC')
  
end