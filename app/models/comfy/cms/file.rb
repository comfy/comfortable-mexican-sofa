class Comfy::Cms::File < ActiveRecord::Base
  self.table_name = 'comfy_cms_files'

  IMAGE_TYPES     = %w(gif jpg jpeg pjpeg png tiff)
  IMAGE_MIMETYPES = (IMAGE_TYPES - ['jpg']).collect{|subtype| "image/#{subtype}"}
  SOME_MIMETYPES  = {doc:  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     pdf:  'application/pdf',
                     xls:  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                     xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'}

  cms_is_categorized

  attr_accessor :dimensions

  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options.merge(
    # dimensions accessor needs to be set before file assignment for this to work
    :styles => lambda { |f|
      if f.respond_to?(:instance) && f.instance.respond_to?(:dimensions)
        (f.instance.dimensions.blank?? { } : { :original => f.instance.dimensions }).merge(
          :cms_thumb => '80x60#'
        ).merge(ComfortableMexicanSofa.config.upload_file_options[:styles] || {})
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
  do_not_validate_attachment_file_type :file

  validates :file_file_name,
    :uniqueness => {:scope => [:site_id, :block_id]}

  # -- Callbacks ------------------------------------------------------------
  before_save   :assign_label
  before_create :assign_position
  after_save    :reload_blockable_cache
  after_destroy :reload_blockable_cache

  # -- Scopes ---------------------------------------------------------------
  scope :not_page_file, -> { where(:block_id => nil)}
  scope :images,        -> { where(:file_content_type => IMAGE_MIMETYPES) }
  scope :not_images,    -> { where('file_content_type NOT IN (?)', IMAGE_MIMETYPES) }
  scope :ordered_by,    ->(field) { order("comfy_cms_files.#{field.presence || "position DESC"}") }

  scope :of_type, ->(type) do
    return unless type.present?
    return images if IMAGE_TYPES.include?(type)
    where(file_content_type: SOME_MIMETYPES[type.to_sym]) if SOME_MIMETYPES.keys.include?(type.to_sym)
  end

  scope :search_by, ->(phrase) do
    if phrase.present?
      where("((file_file_name LIKE ?) or (label LIKE ?) or (description LIKE ?))",
            "%#{phrase}%", "%#{phrase}%", "%#{phrase}%")
    end
  end

  # -- Instance Methods -----------------------------------------------------
  def is_image?
    IMAGE_MIMETYPES.include?(file_content_type)
  end

protected

  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end

  def assign_position
    max = Comfy::Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def reload_blockable_cache
    return unless self.block
    b = self.block.blockable
    b.class.name.constantize.where(:id => b.id).update_all(:content_cache => nil)
  end

end
