class UpgradeTo1120 < ActiveRecord::Migration
  def self.up
    add_column :cms_blocks, :blockable_type, :string
    add_index :cms_blocks, :blockable_type

    rename_column :cms_blocks, :page_id, :blockable_id
    execute("UPDATE cms_blocks SET blockable_type = 'Cms::Page'")

    rename_column :cms_pages, :content, :content_cache
  end

  def self.down
    remove_index :cms_blocks, :blockable_type
    remove_column :cms_blocks, :blockable_type
    rename_column :cms_blocks, :blockable_id, :page_id
    rename_column :cms_pages, :content_cache, :content
  end
end
