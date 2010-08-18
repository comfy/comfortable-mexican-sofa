class CreateCms < ActiveRecord::Migration
  def self.up
    # -- Layouts ------------------------------------------------------------
    create_table :cms_layouts do |t|
      t.timestamps
    end
    
    # -- Pages --------------------------------------------------------------
    
    create_table :cms_pages do |t|
      t.timestamps
    end
    
    # -- Blocks -------------------------------------------------------------
    
    create_table :cms_blocks do |t|
      t.timestamps
    end
    
    # -- Snippets -----------------------------------------------------------
    
    create_table :cms_snippets do |t|
      t.string  :label
      t.text    :content
      t.timestamps
    end
    add_index :cms_snippets, :label, :unique => true
    
    # -- Assets -------------------------------------------------------------
    
    create_table :cms_assets do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :cms_assets
    drop_table :cms_snippets
    drop_table :cms_blocks
    drop_table :cms_pages
    drop_table :cms_layouts
  end
end
