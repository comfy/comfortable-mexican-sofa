class Cms::Site < ActiveRecord::Base
  
  set_table_name :cms_sites
  
  # -- Relationships --------------------------------------------------------
  has_many :layouts,  :dependent => :destroy
  has_many :pages,    :dependent => :destroy
  has_many :snippets, :dependent => :destroy
  has_many :uploads,  :dependent => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => true,
    :format     => { :with => /^[\w\.\-]+$/ }
    
  # -- Class Methods --------------------------------------------------------
  def self.options_for_select
    Cms::Site.all.collect{|s| ["#{s.label} (#{s.hostname})", s.id]}
  end
  
protected

  def assign_label
    self.label = self.label.blank?? self.hostname : self.label
  end
  
end