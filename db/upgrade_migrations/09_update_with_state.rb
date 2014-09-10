class AddStateToPage < ActiveRecord::Migration
  def change
    add_column :comfy_cms_pages, :state, :string
  end
end
