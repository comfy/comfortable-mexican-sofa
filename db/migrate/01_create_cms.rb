class CreateCms < ActiveRecord::Migration
  
  def self.up
    
    text_limit = case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL'
        { }
      else
        { :limit => 16777215 }
      end
    
    # -- Sites --------------------------------------------------------------
    create_table :comfy_cms_sites do |t|
      t.string :label,        :null => false
      t.string :identifier,   :null => false
      t.string :hostname,     :null => false
      t.string :path
      t.string :locale,       :null => false, :default => 'en'
      t.boolean :is_mirrored, :null => false, :default => false
    end
    add_index :comfy_cms_sites, :hostname
    add_index :comfy_cms_sites, :is_mirrored
    
    # -- Layouts ------------------------------------------------------------
    create_table :comfy_cms_layouts do |t|
      t.integer :site_id,     :null => false
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label,       :null => false
      t.string  :identifier,  :null => false
      t.text    :content,     text_limit
      t.text    :css,         text_limit
      t.text    :js,          text_limit
      t.integer :position,    :null => false, :default => 0
      t.boolean :is_shared,   :null => false, :default => false
      t.timestamps
    end
    add_index :comfy_cms_layouts, [:parent_id, :position]
    add_index :comfy_cms_layouts, [:site_id, :identifier], :unique => true
    
    # -- Pages --------------------------------------------------------------
    create_table :comfy_cms_pages do |t|
      t.integer :site_id,         :null => false
      t.integer :layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label,           :null => false
      t.string  :slug
      t.string  :full_path,       :null => false
      t.text    :content_cache,   text_limit
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.boolean :is_published,    :null => false, :default => true
      t.boolean :is_shared,       :null => false, :default => false
      t.timestamps
    end
    add_index :comfy_cms_pages, [:site_id, :full_path]
    add_index :comfy_cms_pages, [:parent_id, :position]
    
    # -- Page Blocks --------------------------------------------------------
    create_table :comfy_cms_blocks do |t|
      t.string     :identifier,  :null => false
      t.text       :content,     text_limit
      t.references :blockable, :polymorphic => true
      t.timestamps
    end
    add_index :comfy_cms_blocks, [:identifier]
    add_index :comfy_cms_blocks, [:blockable_id, :blockable_type]
    
    # -- Snippets -----------------------------------------------------------
    create_table :comfy_cms_snippets do |t|
      t.integer :site_id,     :null => false
      t.string  :label,       :null => false
      t.string  :identifier,  :null => false
      t.text    :content,     text_limit
      t.integer :position,    :null => false, :default => 0
      t.boolean :is_shared,   :null => false, :default => false
      t.timestamps
    end
    add_index :comfy_cms_snippets, [:site_id, :identifier], :unique => true
    add_index :comfy_cms_snippets, [:site_id, :position]
    
    # -- Files --------------------------------------------------------------
    create_table :comfy_cms_files do |t|
      t.integer :site_id,           :null => false
      t.integer :block_id
      t.string  :label,             :null => false
      t.string  :file_file_name,    :null => false
      t.string  :file_content_type, :null => false
      t.integer :file_file_size,    :null => false
      t.string  :description,       :limit => 2048
      t.integer :position,          :null => false, :default => 0
      t.timestamps
    end
    add_index :comfy_cms_files, [:site_id, :label]
    add_index :comfy_cms_files, [:site_id, :file_file_name]
    add_index :comfy_cms_files, [:site_id, :position]
    add_index :comfy_cms_files, [:site_id, :block_id]
    
    # -- Revisions -----------------------------------------------------------
    create_table :comfy_cms_revisions, :force => true do |t|
      t.string    :record_type, :null => false
      t.integer   :record_id,   :null => false
      t.text      :data,        text_limit
      t.datetime  :created_at
    end
    add_index :comfy_cms_revisions, [:record_type, :record_id, :created_at],
      :name => 'index_cms_revisions_on_rtype_and_rid_and_created_at'
    
    # -- Categories ---------------------------------------------------------
    create_table :comfy_cms_categories, :force => true do |t|
      t.integer :site_id,          :null => false
      t.string  :label,            :null => false
      t.string  :categorized_type, :null => false
    end
    add_index :comfy_cms_categories, [:site_id, :categorized_type, :label], :unique => true,
      :name => 'index_cms_categories_on_site_id_and_cat_type_and_label'
    
    create_table :comfy_cms_categorizations, :force => true do |t|
      t.integer :category_id,       :null => false
      t.string  :categorized_type,  :null => false
      t.integer :categorized_id,    :null => false
    end
    add_index :comfy_cms_categorizations, [:category_id, :categorized_type, :categorized_id], :unique => true,
      :name => 'index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id'
  end
  
  def self.down
    drop_table :comfy_cms_sites
    drop_table :comfy_cms_layouts
    drop_table :comfy_cms_pages
    drop_table :comfy_cms_snippets
    drop_table :comfy_cms_blocks
    drop_table :comfy_cms_files
    drop_table :comfy_cms_revisions
    drop_table :comfy_cms_categories
    drop_table :comfy_cms_categorizations
  end
end

