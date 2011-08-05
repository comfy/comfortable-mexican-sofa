class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    rename_table :cms_uploads, :cms_files
  end
  
  def self.down
    rename_table :cms_files, :cms_uploads
  end
end