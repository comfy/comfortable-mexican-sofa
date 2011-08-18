class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    rename_table :cms_uploads, :cms_files
    add_column :cms_files, :label, :string
    add_column :cms_files, :description, :string, :limit => 2048
    add_index :cms_files, [:site_id, :label]
  end
  
  def self.down
    remove_index :cms_files, [:site_id, :label]
    remove_column :cms_files, :description
    remove_column :cms_files, :label
    rename_table :cms_files, :cms_uploads
  end
end