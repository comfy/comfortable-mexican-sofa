class AddContentToPageContent < ActiveRecord::Migration
  def change
    add_column :cms_page_contents, :content, :text
  end
end
