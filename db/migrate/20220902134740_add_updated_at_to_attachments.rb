class AddUpdatedAtToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :active_storage_attachments, :updated_at, :datetime, null: false
  end
end
