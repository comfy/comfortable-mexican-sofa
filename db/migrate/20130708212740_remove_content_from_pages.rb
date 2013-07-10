class RemoveContentFromPages < ActiveRecord::Migration
  def change
    remove_column :cms_pages, :content
  end
end
