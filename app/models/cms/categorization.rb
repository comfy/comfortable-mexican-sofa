class Cms::Categorization < ActiveRecord::Base
  establish_connection "#{ComfortableMexicanSofa.config.database_prefix}#{Rails.env}"
  
  set_table_name :cms_categorizations
  
  # -- Relationships --------------------------------------------------------
  belongs_to :category
  belongs_to :categorized,
    :polymorphic => true
    
  # -- Validations ----------------------------------------------------------
  validates :categorized_type, :categorized_id,
    :presence   => true
  validates :category_id,
    :presence   => true,
    :uniqueness => { :scope => [:categorized_type, :categorized_id] }
  
end
