class UpgradeTo130 < ActiveRecord::Migration
  def self.up
    ComfortableMexicanSofa.establish_connection(ActiveRecord::Base)
    add_column :cms_sites, :is_mirrored, :boolean, :null => false, :default => false
    add_column :cms_sites, :path, :string
    add_column :cms_sites, :locale, :string, :null => false, :default => 'en'
    add_index :cms_sites, :is_mirrored 
    
    add_column :cms_layouts,  :is_shared, :boolean, :null => false, :default => false
    add_column :cms_pages,    :is_shared, :boolean, :null => false, :default => false
    add_column :cms_snippets, :is_shared, :boolean, :null => false, :default => false
    ActiveRecord::Base.establish_connection
  end

  def self.down
    ComfortableMexicanSofa.establish_connection(ActiveRecord::Base)
    remove_index :cms_sites, :is_mirrored
    remove_column :cms_sites, :path
    remove_column :cms_sites, :is_mirrored
    remove_column :cms_sites, :locale
    
    remove_column :cms_layouts,   :is_shared
    remove_column :cms_pages,     :is_shared
    remove_column :cms_snippets,  :is_shared
    ActiveRecord::Base.establish_connection
  end
end