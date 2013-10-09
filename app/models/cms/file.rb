class Cms::File < ActiveRecord::Base
  include Cms::Base
  
  IMAGE_MIMETYPES = %w(gif jpeg pjpeg png tiff).collect{|subtype| "image/#{subtype}"}
  
  cms_is_categorized
  
  attr_accessor :dimensions
  
  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options.merge(
    # dimensions accessor needs to be set before file assignment for this to work
    :styles => lambda { |f|
      if f.respond_to?(:instance) && f.instance.respond_to?(:dimensions)
        (f.instance.dimensions.blank?? { } : { :original => f.instance.dimensions }).merge(
          :cms_thumb => '80x60#'
        )
      end
    }
  )
  before_post_process :is_image?
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :block
  
  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates_attachment_presence :file
  validates :file_file_name,
    :uniqueness => {:scope => :site_id}
  
  # -- Callbacks ------------------------------------------------------------
  before_save   :assign_label
  before_create :assign_position
  after_save    :reload_page_cache
  after_destroy :reload_page_cache
  
  # -- Scopes ---------------------------------------------------------------
  scope :images,      -> { where(:file_content_type => IMAGE_MIMETYPES) }
  scope :not_images,  -> { where('file_content_type NOT IN (?)', IMAGE_MIMETYPES) }
  
  # -- Instance Methods -----------------------------------------------------
  def is_image?
    IMAGE_MIMETYPES.include?(file_content_type)
  end
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end
  
  def assign_position
    max = Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
  def reload_page_cache
    return unless self.block
    p = self.block.page
    Cms::Page.where(:id => p.id).update_all(:content => nil)
  end
  
end
