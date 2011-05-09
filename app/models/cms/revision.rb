class Cms::Revision < ActiveRecord::Base
  
  set_table_name :cms_revisions
  
  serialize :data
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order('created_at DESC')
  
end