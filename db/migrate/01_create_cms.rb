class CreateCms < ActiveRecord::Migration
  def self.up
    create_table :cms_layouts do |t|
      t.timestamps
    end
    
    create_table :cms_pages do |t|
      t.timestamps
    end
    
    create_table :cms_blocks do |t|
      t.timestamps
    end
    
    create_table :cms_snippets do |t|
      t.timestamps
    end
    
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
