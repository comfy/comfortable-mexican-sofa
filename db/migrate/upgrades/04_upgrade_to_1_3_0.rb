class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    add_column :cms_sites, :is_mirrored, :boolean, :null => false, :default => false
    add_column :cms_sites, :path, :string
    add_column :cms_sites, :locale, :string, :null_false, :default => 'en'
    add_index :cms_sites, :is_mirrored
  end

  def self.down
    remove_index :cms_sites, :is_mirrored
    remove_column :cms_sites, :path
    remove_column :cms_sites, :is_mirrored
    remove_column :cms_sites, :locale
  end
end