class CreateCms < ActiveRecord::Migration
  
  def self.up
    
    # -- Layouts ------------------------------------------------------------
    create_table :cms_layouts do |t|
      t.string  :label
      t.text    :content
      t.timestamps
    end
    add_index :cms_layouts, :label
    
    # -- Pages --------------------------------------------------------------
    create_table :cms_pages do |t|
      t.integer :cms_layout_id
      t.integer :parent_id
      t.string  :label
      t.string  :slug
      t.string  :full_path
      t.text    :content
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.timestamps
    end
    add_index :cms_pages, :full_path
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
    # TODO: index this
    
    # -- Snippets -----------------------------------------------------------
    create_table :cms_snippets do |t|
      t.string  :label
      t.text    :content
      t.timestamps
    end
    add_index :cms_snippets, :label, :unique => true
    
    # -- Assets -------------------------------------------------------------
    create_table :cms_assets do |t|
      t.string  :cms_page_id
      t.string  :file_file_name
      t.string  :file_content_type
      t.integer :file_file_size
      t.timestamps
    end
    add_index :cms_assets, :cms_page_id
  end
  
  def self.down
    drop_table :cms_layouts
    drop_table :cms_pages
    drop_table :cms_snippets
    drop_table :cms_blocks
    drop_table :cms_assets
  end
end
