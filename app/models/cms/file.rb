class Cms::File < ActiveRecord::Base
  
  IMAGE_MIMETYPES = %w(gif jpeg pjpeg png svg+xml tiff).collect{|subtype| "image/#{subtype}"}
  
  ComfortableMexicanSofa.establish_connection(self)
    
  set_table_name :cms_files
  
  cms_is_categorized
  
  attr_accessor :dimensions
  
  # -- AR Extensions --------------------------------------------------------
  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options.merge(
    # dimensions accessor needs to be set before file assignment for this to work
    :styles => lambda { |f|
      f.instance.dimensions.blank?? { } : { :original => f.instance.dimensions }
    }
  )
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :block
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, :presence => true
  validates_attachment_presence :file
  
  # -- Callbacks ------------------------------------------------------------
  before_save   :assign_label
  before_create :assign_position
  after_save    :reload_page_cache
  after_destroy :reload_page_cache
  
  # -- Scopes ---------------------------------------------------------------
  scope :images,      where(:file_content_type => IMAGE_MIMETYPES)
  scope :not_images,  where('file_content_type NOT IN (?)', IMAGE_MIMETYPES)
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end
  
  def assign_position
    max = Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
  # FIX: Terrible, but no way of creating cached page content overwise
  def reload_page_cache
    return unless self.block
    p = self.block.page
    p.update_column(:content, p.content(true))
  end
  
end
