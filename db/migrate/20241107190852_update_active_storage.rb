class UpdateActiveStorage < ActiveRecord::Migration[7.2]
  def change
    add_column :active_storage_blobs, :service_name, :string, null: false
    change_column :active_storage_blobs, :checksum, :string, null: true

    if configured_service = ActiveStorage::Blob.service.name
      ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)
    end

    create_table :active_storage_variant_records, id: primary_key_type, if_not_exists: true do |t|
      t.belongs_to :blob, null: false, index: false, type: blobs_primary_key_type
      t.string :variation_digest, null: false

      t.index %i[ blob_id variation_digest ], name: "index_active_storage_variant_records_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  private

  def primary_key_type
    config = Rails.configuration.generators
    config.options[config.orm][:primary_key_type] || :primary_key
  end

  def blobs_primary_key_type
    pkey_name = connection.primary_key(:active_storage_blobs)
    pkey_column = connection.columns(:active_storage_blobs).find { |c| c.name == pkey_name }
    pkey_column.bigint? ? :bigint : pkey_column.type
  end
end
