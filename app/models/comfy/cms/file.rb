class Comfy::Cms::File < ActiveRecord::Base
  self.table_name = "comfy_cms_files"

  include Comfy::Cms::WithCategories

  VARIANT_SIZE = {
    redactor: {resize: "100x75^",   gravity: "center", crop: "100x75+0+0"},
    thumb:    {resize: "200x150^",  gravity: "center", crop: "200x150+0+0"},
    icon:     {resize: "28x28^",    gravity: "center", crop: "28x28+0+0"}
  }.freeze

  # temporary place to store attachment
  attr_accessor :file

  has_one_attached :attachment

  # -- Relationships -----------------------------------------------------------
  belongs_to :site

  # -- Callbacks ---------------------------------------------------------------
  before_create :assign_position
  after_save :process_attachment

  # -- Validations -------------------------------------------------------------
  validates :file, presence: true, on: :create

  # -- Scopes ------------------------------------------------------------------
  # When we need to grab only files with image attachments.
  # Don't forget to include `with_attached_attachment` before calling this
  scope :with_images, -> {
    where("active_storage_blobs.content_type LIKE 'image/%'").references(:blob)
  }

  # -- Instance Methods --------------------------------------------------------
  def label
    l = read_attribute(:label)
    return l if l.present?
    attachment.attached?? attachment.filename.to_s : nil
  end

protected

  def assign_position
    max = Comfy::Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def process_attachment
    return if @file.blank?
    attachment.attach(@file)
  end
end
