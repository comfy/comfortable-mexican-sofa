class AddPreviewCacheToPage < ActiveRecord::Migration
  def change
    add_column :comfy_cms_pages, :preview_cache, :string
  end
end
