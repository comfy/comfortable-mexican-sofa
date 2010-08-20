class CmsSite < ActiveRecord::Base
  # -- Relationships --------------------------------------------------------

  has_many :cms_pages,
    :dependent => :destroy

  has_many :hostnames,
    :class_name => 'CmsSiteHostname',
    :dependent => :destroy

  accepts_nested_attributes_for :hostnames,
    :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['hostname'].blank? }
  
  # -- Validations ----------------------------------------------------------

  validates_presence_of :label
  validates_uniqueness_of :label

  validates_presence_of :hostname
  validates_uniqueness_of :hostname
  
  # -- Scopes ---------------------------------------------------------------

  default_scope :order => 'label ASC'
  
  # -- Callbacks ------------------------------------------------------------
  
  after_create :create_page
  
  # -- Class Methods --------------------------------------------------------

  def self.options_for_select
    [ [ '---', nil ] ] + CmsSite.all.collect { |l| [ l.label, l.id ] }
  end
  
  # -- Instance Methods -----------------------------------------------------
  
protected
  def create_page
    self.cms_pages.create!(
      :label => self.label,
      :cms_layout => CmsLayout.first,
      :site_root => true
    )
    
    self.save(false) if (self.changed?)
  end
end
