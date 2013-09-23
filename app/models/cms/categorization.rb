class Cms::Categorization < Cms::Base
  
  attr_accessible :categorized
  
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
