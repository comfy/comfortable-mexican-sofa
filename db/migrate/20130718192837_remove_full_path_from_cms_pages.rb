class RemoveFullPathFromCmsPages < ActiveRecord::Migration
  def change
    remove_column :cms_pages, :full_path
  end
end
