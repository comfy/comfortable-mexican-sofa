# frozen_string_literal: true

class Comfy::Cms::File < ActiveRecord::Base

  self.table_name = "comfy_cms_files"

  include Comfy::Cms::WithCategories

  VARIANT_SIZE = {
    redactor: { resize_to_fill: [100, 75],   gravity: "center", crop: [0, 0, 100, 75] },
    thumb:    { resize_to_fill: [200, 150],  gravity: "center", crop: [0, 0, 200, 150] },
    icon:     { resize_to_fill: [28, 28],    gravity: "center", crop: [0, 0, 28, 28] }
  }.freeze

  # temporary place to store attachment
  attr_accessor :file

  has_one_attached :attachment

  # -- Relationships -----------------------------------------------------------
  belongs_to :site

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_label, on: :create
  before_create :assign_position
  # active_storage attachment behavior changed in rails 6 - see PR#892 for details
  if Rails::VERSION::MAJOR >= 6
    before_save :process_attachment
  else
    after_save :process_attachment
  end

  after_save    :clear_page_content_cache

  # -- Validations -------------------------------------------------------------
  validates :label, presence: true
  validates :file, presence: true, on: :create

  # -- Scopes ------------------------------------------------------------------
  # When we need to grab only files with image attachments.
  # Don't forget to include `with_attached_attachment` before calling this
  scope :with_images, -> {
    where("active_storage_blobs.content_type LIKE 'image/%'").references(:blob)
  }

private

def clear_page_content_cache
  Comfy::Cms::Page.where(id: site.pages.pluck(:id)).update_all(content_cache: nil)
end

protected

  def assign_position
    max = Comfy::Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  # TODO: Change db schema not to set blank string
  def assign_label
    return if label.present?
    self.label = file&.original_filename
  end

  def process_attachment
    return if @file.blank?
    self.attachment = @file
  end

end
