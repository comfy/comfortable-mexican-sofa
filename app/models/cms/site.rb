class Cms::Site < ActiveRecord::Base
  
  set_table_name :cms_sites
  
  # -- Relationships --------------------------------------------------------
  has_many :layouts,  :dependent => :destroy
  has_many :pages,    :dependent => :destroy
  has_many :snippets, :dependent => :destroy
  has_many :uploads,  :dependent => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  before_save :clean_path
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => { :scope => :path },
    :format     => { :with => /^[\w\.\-]+$/ }
    
  # -- Scopes ---------------------------------------------------------------
  scope :mirrored, where(:is_mirrored => true)
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.hostname : self.label
  end
  
  def clean_path
    self.path ||= ''
    self.path.squeeze!('/')
    self.path.gsub!(/\/$/, '')
  end
  
end