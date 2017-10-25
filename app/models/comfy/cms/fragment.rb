class Comfy::Cms::Fragment < ActiveRecord::Base
  self.table_name = 'comfy_cms_fragments'

  has_many_attached :attachments

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

  # Based on the fragment format we need to properly process incoming content.
  # Content that is getting returned also needs to be controlled the same way.
  # So we need to make sure that format gets assigned before content. Meaning
  # that attributes hash needs to be ordered like so:
  #   {format: "text", content: "some content"}
  # If format key comes after content we're in trouble as it will be processed
  # as text.
  def content=(content)
    case self.format
    when "datetime", "date"
      write_attribute(:datetime, content)
      content_will_change! if datetime_changed?
    when "boolean"
      write_attribute(:boolean, content)
    when "file", "files"
      @temp_files = [content].flatten.reject{|f| f.blank?}
      content_will_change! if @temp_files.present?
    else
      write_attribute(:content, content)
    end
  end

  def content
    case self.format
    when "datetime", "date"
      read_attribute(:datetime)
    when "boolean"
      read_attribute(:boolean)
    when "file", "files"
      @temp_files || attachments.to_a
    else
      read_attribute(:content)
    end
  end

protected

  def process_attachments
    return if @temp_files.blank?

    # If we're dealing with a single file
    # if self.attachments && self.format == "file"
    #   self.attachments.purge_later
    # end

    self.attachments.attach(@temp_files)
  end
end
