class DeviseCreateCmsUsers < ActiveRecord::Migration
  def change

    create_table(:cms_site_users) do |t|
      t.integer :site_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    create_table(:cms_users) do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token
      
      ## Other stuff
      t.boolean :super_admin, null: false, default: false


      t.timestamps
    end

    add_index :cms_users, :email,                :unique => true
    add_index :cms_users, :reset_password_token, :unique => true
    add_index :cms_site_users, :site_id
    add_index :cms_site_users, :user_id
    add_index :cms_site_users, [:site_id, :user_id], unique: true
  end
end
