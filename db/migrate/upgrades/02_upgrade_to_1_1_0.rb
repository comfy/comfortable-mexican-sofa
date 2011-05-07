class UpgradeTo110 < ActiveRecord::Migration
  def self.up
    rename_column :cms_layouts,   :cms_site_id,   :site_id
    rename_column :cms_pages,     :cms_site_id,   :site_id
    rename_column :cms_pages,     :cms_layout_id, :layout_id
    rename_column :cms_blocks,    :cms_page_id,   :page_id
    rename_column :cms_snippets,  :cms_site_id,   :site_id
    rename_column :cms_uploads,   :cms_site_id,   :site_id
  end

  def self.down
    rename_column :cms_uploads,   :site_id,   :cms_site_id
    rename_column :cms_snippets,  :site_id,   :cms_site_id
    rename_column :cms_blocks,    :page_id,   :cms_page_id
    rename_column :cms_layouts,   :site_id,   :cms_site_id
    rename_column :cms_pages,     :layout_id, :cms_layout_id
    rename_column :cms_pages,     :site_id,   :cms_site_id
  end
end