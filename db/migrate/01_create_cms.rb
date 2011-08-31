class CreateCms < ActiveRecord::Migration
  
  def self.up
    ActiveRecord::Base.establish_connection "#{ComfortableMexicanSofa.config.database_config}#{Rails.env}"
    # -- Sites --------------------------------------------------------------
    create_table :cms_sites do |t|
      t.string :label
      t.string :hostname
      t.string :path
      t.string :locale,       :null => false, :default => 'en'
      t.boolean :is_mirrored, :null => false, :default => false
    end
    add_index :cms_sites, :hostname
    add_index :cms_sites, :is_mirrored
    
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
      t.integer :position,  :null => false, :default => 0
      t.boolean :is_shared, :null => false, :default => false
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
      t.boolean :is_shared,       :null => false, :default => false
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
      t.boolean :is_shared, :null => false, :default => false
      t.timestamps
    end
    add_index :cms_snippets, [:site_id, :slug], :unique => true
    
    # -- Files --------------------------------------------------------------
    create_table :cms_files do |t|
      t.integer :site_id
      t.string  :label
      t.string  :file_file_name
      t.string  :file_content_type
      t.integer :file_file_size
      t.string  :description, :limit => 2048
      t.timestamps
    end
    add_index :cms_files, [:site_id, :label]
    add_index :cms_files, [:site_id, :file_file_name]
    
    # -- Revisions -----------------------------------------------------------
    create_table :cms_revisions, :force => true do |t|
      t.string    :record_type
      t.integer   :record_id
      t.text      :data
      t.datetime  :created_at
    end
    add_index :cms_revisions, [:record_type, :record_id, :created_at]
    
    # -- Categories ---------------------------------------------------------
    create_table :cms_categories, :force => true do |t|
      t.string :label
      t.string :categorized_type
    end
    add_index :cms_categories, [:categorized_type, :label], :unique => true
    
    create_table :cms_categorizations, :force => true do |t|
      t.integer :category_id
      t.string :categorized_type
      t.integer :categorized_id
    end
    add_index :cms_categorizations, [:category_id, :categorized_type, :categorized_id], :unique => true,
      :name => 'index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id'
  end
  
  def self.down
    ActiveRecord::Base.establish_connection "#{ComfortableMexicanSofa.config.database_config}#{Rails.env}"
    
    drop_table :cms_sites
    drop_table :cms_layouts
    drop_table :cms_pages
    drop_table :cms_snippets
    drop_table :cms_blocks
    drop_table :cms_files
    drop_table :cms_revisions
    drop_table :cms_categories
    drop_table :cms_categorizations
  end
end
