class UpgradeTo140 < ActiveRecord::Migration
  def self.up
    rename_table :cms_uploads, :cms_files
    add_column :cms_files, :label, :string
    add_column :cms_files, :description, :string, :limit => 2048
    add_index :cms_files, [:site_id, :label]
    
    # -- Categories ---------------------------------------------------------
    create_table :cms_categories, :force => true do |t|
      t.string :label
      t.string :categorized_type
    end
    add_index :cms_categories, [:categorized_type, :label], :unique => true
    
    create_table :cms_categorizations, :force => true do |t|
      t.integer :category_id
      t.string  :categorized_type
      t.integer :categorized_id
    end
    add_index :cms_categorizations, [:category_id, :categorized_type, :categorized_id], :unique => true,
      :name => 'index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id'
  end
  
  def self.down
    remove_index :cms_files, [:site_id, :label]
    remove_column :cms_files, :description
    remove_column :cms_files, :label
    rename_table :cms_files, :cms_uploads
    
    drop_table :cms_categories
    drop_table :cms_categorizations
  end
end