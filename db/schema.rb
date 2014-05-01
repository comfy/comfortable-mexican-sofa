# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cms_blocks", force: true do |t|
    t.integer  "page_id",    null: false
    t.string   "identifier", null: false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_blocks", ["page_id", "identifier"], name: "index_cms_blocks_on_page_id_and_identifier", using: :btree

  create_table "cms_categories", force: true do |t|
    t.integer "site_id",          null: false
    t.string  "label",            null: false
    t.string  "categorized_type", null: false
  end

  add_index "cms_categories", ["site_id", "categorized_type", "label"], name: "index_cms_categories_on_site_id_and_categorized_type_and_label", unique: true, using: :btree

  create_table "cms_categorizations", force: true do |t|
    t.integer "category_id",      null: false
    t.string  "categorized_type", null: false
    t.integer "categorized_id",   null: false
  end

  add_index "cms_categorizations", ["category_id", "categorized_type", "categorized_id"], name: "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id", unique: true, using: :btree

  create_table "cms_files", force: true do |t|
    t.integer  "site_id",                                    null: false
    t.integer  "block_id"
    t.string   "label",                                      null: false
    t.string   "file_file_name",                             null: false
    t.string   "file_content_type",                          null: false
    t.integer  "file_file_size",                             null: false
    t.string   "description",       limit: 2048
    t.integer  "position",                       default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_files", ["site_id", "block_id"], name: "index_cms_files_on_site_id_and_block_id", using: :btree
  add_index "cms_files", ["site_id", "file_file_name"], name: "index_cms_files_on_site_id_and_file_file_name", using: :btree
  add_index "cms_files", ["site_id", "label"], name: "index_cms_files_on_site_id_and_label", using: :btree
  add_index "cms_files", ["site_id", "position"], name: "index_cms_files_on_site_id_and_position", using: :btree

  create_table "cms_layouts", force: true do |t|
    t.integer  "site_id",                    null: false
    t.integer  "parent_id"
    t.string   "app_layout"
    t.string   "label",                      null: false
    t.string   "identifier",                 null: false
    t.text     "content"
    t.text     "head"
    t.text     "css"
    t.text     "js"
    t.integer  "position",   default: 0,     null: false
    t.boolean  "is_shared",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_layouts", ["parent_id", "position"], name: "index_cms_layouts_on_parent_id_and_position", using: :btree
  add_index "cms_layouts", ["site_id", "identifier"], name: "index_cms_layouts_on_site_id_and_identifier", unique: true, using: :btree

  create_table "cms_pages", force: true do |t|
    t.integer  "site_id",                        null: false
    t.integer  "layout_id"
    t.integer  "parent_id"
    t.integer  "target_page_id"
    t.string   "label",                          null: false
    t.string   "slug"
    t.string   "full_path",                      null: false
    t.text     "content"
    t.integer  "position",       default: 0,     null: false
    t.integer  "children_count", default: 0,     null: false
    t.boolean  "is_published",   default: true,  null: false
    t.boolean  "include_in_nav", default: true
    t.boolean  "is_shared",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_pages", ["parent_id", "position"], name: "index_cms_pages_on_parent_id_and_position", using: :btree
  add_index "cms_pages", ["site_id", "full_path"], name: "index_cms_pages_on_site_id_and_full_path", using: :btree

  create_table "cms_revisions", force: true do |t|
    t.string   "record_type", null: false
    t.integer  "record_id",   null: false
    t.text     "data"
    t.datetime "created_at"
  end

  add_index "cms_revisions", ["record_type", "record_id", "created_at"], name: "index_cms_revisions_on_rtype_and_rid_and_created_at", using: :btree

  create_table "cms_site_users", force: true do |t|
    t.integer  "site_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_site_users", ["site_id", "user_id"], name: "index_cms_site_users_on_site_id_and_user_id", unique: true, using: :btree
  add_index "cms_site_users", ["site_id"], name: "index_cms_site_users_on_site_id", using: :btree
  add_index "cms_site_users", ["user_id"], name: "index_cms_site_users_on_user_id", using: :btree

  create_table "cms_sites", force: true do |t|
    t.string  "label",                       null: false
    t.string  "identifier",                  null: false
    t.string  "hostname",                    null: false
    t.string  "path"
    t.string  "locale",      default: "en",  null: false
    t.boolean "is_mirrored", default: false, null: false
  end

  add_index "cms_sites", ["hostname"], name: "index_cms_sites_on_hostname", using: :btree
  add_index "cms_sites", ["is_mirrored"], name: "index_cms_sites_on_is_mirrored", using: :btree

  create_table "cms_snippets", force: true do |t|
    t.integer  "site_id",                    null: false
    t.string   "label",                      null: false
    t.string   "identifier",                 null: false
    t.text     "content"
    t.integer  "position",   default: 0,     null: false
    t.boolean  "is_shared",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_snippets", ["site_id", "identifier"], name: "index_cms_snippets_on_site_id_and_identifier", unique: true, using: :btree
  add_index "cms_snippets", ["site_id", "position"], name: "index_cms_snippets_on_site_id_and_position", using: :btree

  create_table "cms_users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "super_admin",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_users", ["email"], name: "index_cms_users_on_email", unique: true, using: :btree
  add_index "cms_users", ["reset_password_token"], name: "index_cms_users_on_reset_password_token", unique: true, using: :btree

end
