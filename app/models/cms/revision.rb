class Cms::Revision < Cms::Base
  
  serialize :data
  
  attr_accessible :data
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order('created_at DESC')
  
end