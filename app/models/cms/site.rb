class Cms::Site < ActiveRecord::Base
  
  set_table_name :cms_sites
  
  # -- Relationships --------------------------------------------------------
  has_many :layouts,  :dependent => :destroy
  has_many :pages,    :dependent => :destroy
  has_many :snippets, :dependent => :destroy
  has_many :uploads,  :dependent => :destroy
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => true
  validates :hostname,
    :presence   => true,
    :uniqueness => true,
    :format     => { :with => /^[\w\.\-]+$/ }
    
  # -- Class Methods --------------------------------------------------------
  def self.options_for_select
    Cms::Site.all.collect{|s| ["#{s.label} (#{s.hostname})", s.id]}
  end
  
end