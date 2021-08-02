# This migration comes from active_storage (originally 20190112182829)
class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:active_storage_blobs, :service_name)
      # Allow to be null to support Rails < 6.1
      add_column :active_storage_blobs, :service_name, :string, null: true
    end
  end

  def down
    remove_column :active_storage_blobs, :service_name
  end
end
