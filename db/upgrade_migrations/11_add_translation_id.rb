class AddTranslationId < ActiveRecord::Migration
  def change
    add_column :comfy_cms_pages, :translation_id, :string
  end
end
