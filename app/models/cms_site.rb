class CmsSite < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  has_many :cms_layouts,  :dependent => :destroy
  has_many :cms_pages,    :dependent => :destroy
  has_many :cms_snippets, :dependent => :destroy
  has_many :cms_uploads,  :dependent => :destroy
  
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
    CmsSite.all.collect{|s| ["#{s.label} (#{s.hostname})", s.id]}
  end
  
end