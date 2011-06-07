class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    add_column :cms_sites, :is_mirrored, :boolean, :null => false, :default => false
    add_column :cms_sites, :path, :string, :null => false, :default => '/'
    remove_index :cms_sites, :hostname
    add_index :cms_sites, [:hostname, :path]
    add_index :cms_sites, :is_mirrored
  end

  def self.down
    remove_index :cms_sites, [:hostname, :path]
    remove_index :cms_sites, :is_mirrored
    add_index :cms_sites, :hostname
    remove_column :cms_sites, :path
    remove_column :cms_sites, :is_mirrored
  end
end