class Comfy::Cms::Fragment < ActiveRecord::Base
  self.table_name = 'comfy_cms_fragments'

  has_many_attached :attachments

  serialize :content

  attr_accessor :file_ids_destroy

  # -- Callbacks ---------------------------------------------------------------
  after_save  :remove_attachments,
              :add_attachments

  # -- Relationships -----------------------------------------------------------
  belongs_to :page

  # -- Validations -------------------------------------------------------------
  validates :identifier,
    presence:   true,
    uniqueness: {scope: :page_id}

  # -- Instance Methods --------------------------------------------------------

  # Temporary accessor for uploaded files. We can only attach to persisted
  # records so we are deffering it to the after_save callback.
  # Note: hijacking dirty tracking to force trigger callbacks later.
  def files=(files)
    @files = [files].flatten.compact
    content_will_change! if @files.present?
  end

  def files
    @files || []
  end

protected

  def remove_attachments
    self.attachments.where(id: self.file_ids_destroy).destroy_all
  end

  def add_attachments
    return if self.files.blank?

    # If we're dealing with a single file
    if self.format == "file"
      self.files = [self.files.first]
      self.attachments.purge_later if self.attachments
    end

    self.attachments.attach(self.files)
  end
end
