class CmsLayout < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  has_many :cms_pages, :dependent => :nullify
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => true
  validates :content,
    :presence   => true
  
end
