class Cms::Category < ActiveRecord::Base
  establish_connection "#{ComfortableMexicanSofa.config.database_prefix}#{Rails.env}"
  
  set_table_name :cms_categories
  
  # -- Relationships --------------------------------------------------------
  has_many :categorizations,
    :dependent => :destroy
    
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :categorized_type }
  validates :categorized_type,
    :presence   => true
    
  # -- Scopes ---------------------------------------------------------------
  default_scope order(:label)
  scope :of_type, lambda { |type|
    where(:categorized_type => type)
  }
  
end