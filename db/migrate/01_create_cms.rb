class CreateCms < ActiveRecord::Migration
  
  def self.up
    # -- Sites --------------------------------------------------------------
    create_table :cms_sites do |t|
      t.string :label
      t.string :hostname
    end
    add_index :cms_sites, :hostname
    
    # -- Layouts ------------------------------------------------------------
    create_table :cms_layouts do |t|
      t.integer :site_id
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label
      t.string  :slug
      t.text    :content
      t.text    :css
      t.text    :js
      t.integer :position, :null => false, :default => 0
      t.timestamps
    end
    add_index :cms_layouts, [:parent_id, :position]
    add_index :cms_layouts, [:site_id, :slug], :unique => true
    
    # -- Pages --------------------------------------------------------------
    create_table :cms_pages do |t|
      t.integer :site_id
      t.integer :layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label
      t.string  :slug
      t.string  :full_path
      t.text    :content
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.boolean :is_published,    :null => false, :default => true
      t.timestamps
    end
    add_index :cms_pages, [:site_id, :full_path]
    add_index :cms_pages, [:parent_id, :position]
    
    # -- Page Blocks --------------------------------------------------------
    create_table :cms_blocks do |t|
      t.integer   :page_id
      t.string    :label
      t.text      :content
      t.timestamps
    end
    add_index :cms_blocks, [:page_id, :label]
    
    # -- Snippets -----------------------------------------------------------
    create_table :cms_snippets do |t|
      t.integer :site_id
      t.string  :label
      t.string  :slug
      t.text    :content
      t.timestamps
    end
    add_index :cms_snippets, [:site_id, :slug], :unique => true
    
    # -- Assets -------------------------------------------------------------
    create_table :cms_uploads do |t|
      t.integer :site_id
      t.string  :file_file_name
      t.string  :file_content_type
      t.integer :file_file_size
      t.timestamps
    end
    add_index :cms_uploads, [:site_id, :file_file_name]
  end
  
  def self.down
    drop_table :cms_sites
    drop_table :cms_layouts
    drop_table :cms_pages
    drop_table :cms_snippets
    drop_table :cms_blocks
    drop_table :cms_uploads
  end
end
