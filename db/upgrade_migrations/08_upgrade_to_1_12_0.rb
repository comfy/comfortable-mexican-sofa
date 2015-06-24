class UpgradeTo1120 < ActiveRecord::Migration
  
  COMFY_CLASSES = %w(Block Category Categorization File Layout Page Revision Site Snippet)
  
  def self.up
    add_column :cms_blocks, :blockable_type, :string
    add_index :cms_blocks, :blockable_type

    rename_column :cms_blocks, :page_id, :blockable_id
    execute("UPDATE cms_blocks SET blockable_type = 'Comfy::Cms::Page'")

    rename_column :cms_pages, :content, :content_cache
    
    rename_table :cms_sites,            :comfy_cms_sites
    rename_table :cms_layouts,          :comfy_cms_layouts
    rename_table :cms_pages,            :comfy_cms_pages
    rename_table :cms_blocks,           :comfy_cms_blocks
    rename_table :cms_snippets,         :comfy_cms_snippets
    rename_table :cms_files,            :comfy_cms_files
    rename_index :cms_revisions,
      'index_cms_revisions_on_record_type_and_record_id_and_created_at',
      'index_cms_revisions_on_record_type_id_and_created'
    rename_table :cms_revisions,        :comfy_cms_revisions
    rename_index :cms_categories,
      'index_cms_categories_on_site_id_and_categorized_type_and_label',
      'index_cms_categories_on_site_id_and_cat_type_and_label'
    rename_table :cms_categories,       :comfy_cms_categories
    rename_table :cms_categorizations,  :comfy_cms_categorizations
    
    COMFY_CLASSES.each do |klass|
      execute("
        UPDATE comfy_cms_categories SET categorized_type = 'Comfy::Cms::#{klass}'
        WHERE categorized_type = 'Cms::#{klass}'
      ")
      execute("
        UPDATE comfy_cms_categorizations SET categorized_type = 'Comfy::Cms::#{klass}'
        WHERE categorized_type = 'Cms::#{klass}'
      ")
      execute("
        UPDATE comfy_cms_revisions SET record_type = 'Comfy::Cms::#{klass}'
        WHERE record_type = 'Cms::#{klass}'
      ")
    end
  end

  def self.down
    COMFY_CLASSES.each do |klass| 
      execute("
        UPDATE comfy_cms_revisions SET record_type = 'Cms::#{klass}'
        WHERE record_type = 'Comfy::Cms::#{klass}'
      ")
      execute("
        UPDATE comfy_cms_categorizations SET categorized_type = 'Cms::#{klass}'
        WHERE categorized_type = 'Comfy::Cms::#{klass}'
      ")
      execute("
        UPDATE comfy_cms_categories SET categorized_type = 'Cms::#{klass}'
        WHERE categorized_type = 'Comfy::Cms::#{klass}'
      ")
    end
    
    rename_table :comfy_cms_sites,            :cms_sites
    rename_table :comfy_cms_layouts,          :cms_layouts
    rename_table :comfy_cms_pages,            :cms_pages
    rename_table :comfy_cms_blocks,           :cms_blocks
    rename_table :comfy_cms_snippets,         :cms_snippets
    rename_table :comfy_cms_files,            :cms_files
    rename_index :comfy_cms_revisions,
      'index_cms_revisions_on_record_type_id_and_created',
      'index_cms_revisions_on_record_type_and_record_id_and_created_at'
    rename_table :comfy_cms_revisions,        :cms_revisions
    rename_index :comfy_cms_categories,
      'index_cms_categories_on_site_id_and_cat_type_and_label',
      'index_cms_categories_on_site_id_and_categorized_type_and_label'
    rename_table :comfy_cms_categories,       :cms_categories
    rename_table :comfy_cms_categorizations,  :cms_categorizations
    
    remove_index :cms_blocks, :blockable_type
    remove_column :cms_blocks, :blockable_type
    rename_column :cms_blocks, :blockable_id, :page_id
    rename_column :cms_pages, :content_cache, :content
  end
end