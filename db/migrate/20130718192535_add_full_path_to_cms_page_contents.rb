class AddFullPathToCmsPageContents < ActiveRecord::Migration
  def change
    add_column :cms_page_contents, :full_path, :string
  end
end
