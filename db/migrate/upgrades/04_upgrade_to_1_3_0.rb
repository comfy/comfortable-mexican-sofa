class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    add_column :cms_sites, :is_mirrored, :boolean, :null => false, :default => false
    add_column :cms_sites, :path, :string
    add_column :cms_sites, :locale, :string, :null => false, :default => 'en'
    add_index :cms_sites, :is_mirrored 
    
    add_column :cms_layouts,  :is_shared, :boolean, :null => false, :default => false
    add_column :cms_pages,    :is_shared, :boolean, :null => false, :default => false
    add_column :cms_snippets, :is_shared, :boolean, :null => false, :default => false
  end

  def self.down
    remove_index :cms_sites, :is_mirrored
    remove_column :cms_sites, :path
    remove_column :cms_sites, :is_mirrored
    remove_column :cms_sites, :locale
    
    remove_column :cms_layouts,   :is_shared
    remove_column :cms_pages,     :is_shared
    remove_column :cms_snippets,  :is_shared
  end
end