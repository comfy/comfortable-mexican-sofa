class Comfy::Cms::Fragment < ActiveRecord::Base
  self.table_name = 'comfy_cms_fragments'

  has_many_attached :files

  serialize :content

  # -- Callbacks ---------------------------------------------------------------
  after_save :process_attachments

  # -- Relationships -----------------------------------------------------------
  belongs_to :page

  # -- Validations -------------------------------------------------------------
  validates :identifier,
    presence:   true,
    uniqueness: {scope: :page_id}

  # -- Instance Methods --------------------------------------------------------

  # Temporary storage for files as we can't attach to newly initialized Fragment
  def content_files=(*files)
    @content_files = files.flatten
  end

  def content_files
    @content_files || []
  end

protected

  def process_attachments
    return if content_files.blank?
    self.files.attach(content_files)
  end

end
