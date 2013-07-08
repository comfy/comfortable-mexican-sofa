class AddPageContent < ActiveRecord::Migration

  def change
    create_table :cms_page_contents do |t|
      t.integer :page_id
      t.string  :slug
    end
  end


end
