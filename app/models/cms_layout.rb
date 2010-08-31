class CmsLayout < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  has_many :cms_pages, :dependent => :nullify
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => true
  validates :content,
    :presence   => true
    
  # -- Class Methods --------------------------------------------------------
  def self.options_for_select
    CmsLayout.all(:select => 'id, label').collect { |l| [ l.label, l.id ] }
  end
  
end
