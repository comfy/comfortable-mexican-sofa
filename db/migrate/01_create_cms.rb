class CreateCms < ActiveRecord::Migration[5.2]

  def change

    # -- Sites -----------------------------------------------------------------
    create_table :comfy_cms_sites, force: true do |t|
      t.string :label,        null: false
      t.string :identifier,   null: false
      t.string :hostname,     null: false
      t.string :path
      t.string :locale,       null: false, default: 'en'

      t.index :hostname
      t.index :is_mirrored
    end

    # -- Layouts ---------------------------------------------------------------
    create_table :comfy_cms_layouts, force: true do |t|
      t.integer :site_id,     null: false
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label,       null: false
      t.string  :identifier,  null: false
      t.text    :content,     limit: 16777215
      t.text    :css,         limit: 16777215
      t.text    :js,          limit: 16777215
      t.integer :position,    null: false, default: 0
      t.boolean :is_shared,   null: false, default: false
      t.timestamps

      t.index [:parent_id, :position]
      t.index [:site_id, :identifier], unique: true
    end

    # -- Pages -----------------------------------------------------------------
    create_table :comfy_cms_pages, force: true do |t|
      t.integer :site_id,         null: false
      t.integer :layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label,           null: false
      t.string  :slug
      t.string  :full_path,       null: false
      t.text    :content_cache,   limit: 16777215
      t.integer :position,        null: false, default: 0
      t.integer :children_count,  null: false, default: 0
      t.boolean :is_published,    null: false, default: true
      t.boolean :is_shared,       null: false, default: false
      t.timestamps

      t.index [:site_id, :full_path]
      t.index [:parent_id, :position]
    end

    # -- Page Fragments --------------------------------------------------------
    create_table :comfy_cms_fragments, force: true do |t|
      t.integer     :page_id,     null: false
      t.string      :identifier,  null: false
      t.string      :format,      null: false, default: "text"
      t.text        :content,     limit: 16777215
      t.datetime    :datetime
      t.boolean     :boolean
      t.timestamps

      t.index [:identifier]
      t.index [:page_id]
      t.index [:datetime]
      t.index [:boolean]
    end

    # -- Snippets --------------------------------------------------------------
    create_table :comfy_cms_snippets, force: true do |t|
      t.integer :site_id,     null: false
      t.string  :label,       null: false
      t.string  :identifier,  null: false
      t.text    :content,     limit: 16777215
      t.integer :position,    null: false, default: 0
      t.boolean :is_shared,   null: false, default: false
      t.timestamps

      t.index [:site_id, :identifier], unique: true
      t.index [:site_id, :position]
    end

    # -- Revisions -------------------------------------------------------------
    create_table :comfy_cms_revisions, force: true do |t|
      t.string    :record_type, null: false
      t.integer   :record_id,   null: false
      t.text      :data,        limit: 16777215
      t.datetime  :created_at

      t.index [:record_type, :record_id, :created_at],
      name: "index_cms_revisions_on_rtype_and_rid_and_created_at"
    end

    # -- Categories ------------------------------------------------------------
    create_table :comfy_cms_categories, force: true do |t|
      t.integer :site_id,          null: false
      t.string  :label,            null: false
      t.string  :categorized_type, null: false

      t.index [:site_id, :categorized_type, :label],
      unique: true,
      name:   "index_cms_categories_on_site_id_and_cat_type_and_label"
    end

    create_table :comfy_cms_categorizations, force: true do |t|
      t.integer :category_id,       null: false
      t.string  :categorized_type,  null: false
      t.integer :categorized_id,    null: false

      t.index [:category_id, :categorized_type, :categorized_id],
      unique: true,
      name:   "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id"
    end
  end
end
