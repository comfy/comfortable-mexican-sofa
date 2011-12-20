class UpgradeTo160 < ActiveRecord::Migration
  def self.up
    add_column :cms_sites, :identifier, :string
    add_index :cms_sites, :identifier
    
    rename_column :cms_layouts, :slug, :identifier
    rename_column :cms_blocks, :label, :identifier
    rename_column :cms_snippets, :slug, :identifier
    
    add_column :cms_categories, :site_id, :integer, :null => :false
    add_index :cms_categories, [:site_id, :categorized_type, :label], :unique => true
  end
  
  def self.down
    remove_index :cms_categories, [:site_id, :categorized_type, :label], :unique => true
    remove_column :cms_categories, :site_id
    
    rename_column :cms_snippets, :identifier, :slug
    rename_column :cms_blocks, :identifier, :label
    rename_column :cms_layouts, :identifier, :slug
    
    remove_index :cms_sites, :identifier
    remove_column :cms_sites, :identifier
  end
end