class UpgradeTo1150 < ActiveRecord::Migration
  def self.up
    add_column :comfy_cms_categories, :slug, :string
    
    Comfy::Cms::Category.find_in_batches(batch_size: 20).each do |group|
      group.each do |category|
        category.save
      end
    end

    change_column_null :comfy_cms_categories, :slug, false
  end
  
  def self.down
    remove_column :comfy_cms_categories, :slug
  end
end
