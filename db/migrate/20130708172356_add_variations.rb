class AddVariations < ActiveRecord::Migration
  def change
    create_table :cms_variations do |t|
      t.string  :identifier
      t.string  :content_type
      t.integer :content_id
    end
  end
end
