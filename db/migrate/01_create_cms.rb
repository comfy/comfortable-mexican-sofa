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
      t.integer :cms_site_id
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label
      t.text    :content
      t.text    :css
      t.text    :js
      t.integer :position, :null => false, :default => 0
      t.timestamps
    end
    add_index :cms_layouts, [:cms_site_id, :label]
    add_index :cms_layouts, [:parent_id, :position]
    
    # -- Pages --------------------------------------------------------------
    create_table :cms_pages do |t|
      t.integer :cms_site_id
      t.integer :cms_layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label
      t.string  :slug
      t.string  :full_path
      t.text    :content
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.timestamps
    end
    add_index :cms_pages, [:cms_site_id, :full_path]
    add_index :cms_pages, [:parent_id, :position]
    
    # -- Page Blocks --------------------------------------------------------
    create_table :cms_blocks do |t|
      t.string    :type
      t.integer   :cms_page_id
      t.string    :label
      t.string    :content_string
      t.text      :content_text
      t.integer   :content_integer
      t.datetime  :content_datetime
      t.timestamps
    end
    add_index :cms_blocks, [:cms_page_id, :type, :label]
    
    # -- Snippets -----------------------------------------------------------
    create_table :cms_snippets do |t|
      t.integer :cms_site_id
      t.string  :label
      t.string  :slug
      t.text    :content
      t.timestamps
    end
    add_index :cms_snippets, [:cms_site_id, :slug], :unique => true
    
    # -- Assets -------------------------------------------------------------
    create_table :cms_uploads do |t|
      t.integer :cms_site_id
      t.string  :file_file_name
      t.string  :file_content_type
      t.integer :file_file_size
      t.timestamps
    end
    add_index :cms_uploads, [:cms_site_id, :file_file_name]
    
  end
  
  def self.down
    drop_table :cms_sites
    drop_table :cms_hosts
    drop_table :cms_layouts
    drop_table :cms_pages
    drop_table :cms_snippets
    drop_table :cms_blocks
    drop_table :cms_uploads
  end
end
