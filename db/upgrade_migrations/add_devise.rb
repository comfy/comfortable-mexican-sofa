class AddDevise < ActiveRecord::Migration

  def self.change
    create_table(:cms_site_users) do |t|
      t.integer :site_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    create_table(:cms_users) do |t|
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.boolean :super_admin, null: false, default: false
      t.timestamps
    end

    Cms::User.create do |u|
      u.email = "user@example.com"
      u.password = "password"
      u.super_admin = true
    end

    add_index :cms_users, :email,                :unique => true
    add_index :cms_users, :reset_password_token, :unique => true
    add_index :cms_site_users, :site_id
    add_index :cms_site_users, :user_id
    add_index :cms_site_users, [:site_id, :user_id], unique: true

  end
end
