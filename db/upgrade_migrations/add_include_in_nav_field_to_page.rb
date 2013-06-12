class AddIncludeInNavFieldToPage < ActiveRecord::Migration
  def change
  	add_column :cms_pages, :include_in_nav, :boolean, default: true
  end
end