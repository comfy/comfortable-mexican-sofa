class Cms::File < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
    
  set_table_name :cms_files
  
  cms_is_categorized
  
  # -- AR Extensions --------------------------------------------------------
  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, :presence => true
  validates_attachment_presence :file
  
  validates_uniqueness_of :file_file_name,
    :scope => :site_id
    
  # -- Scopes ---------------------------------------------------------------
  default_scope order(:position)
  
  # -- Callbacks ------------------------------------------------------------
  before_save :assign_label
  before_validation :assign_position,
                    :on => :create
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end
  
  def assign_position
    max = Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
end
