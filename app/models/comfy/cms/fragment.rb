# frozen_string_literal: true

class Comfy::Cms::Fragment < Comfy::Cms::ApplicationRecord
  self.table_name = "comfy_cms_fragments"

  has_many_attached :attachments, dependent: :purge_later

  serialize :content, coder: JSON, comparable: true

  # -- Relationships -----------------------------------------------------------
  belongs_to :record, polymorphic: true, touch: true

  # -- Validations -------------------------------------------------------------
  validates :identifier,
            presence:   true,
            uniqueness: { scope: %i[record_type record_id] }

  # -- Instance Methods --------------------------------------------------------
  # Not allowing direct assignment as has_many_attached will replace things
  # unless you also pass in signed_ids. This keeps things simple and working.
  def files=(incoming_files)
    incoming_files = Array.wrap(incoming_files).compact
    return if incoming_files.blank?

    attachments.attach(incoming_files)
  end

  def file_ids_destroy=(ids)
    ids = Array.wrap(ids).compact
    return if ids.blank?

    attachments.where(id: ids).find_each(&:purge_later)
  end
end
