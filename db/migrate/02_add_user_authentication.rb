class AddUserAuthentication < ActiveRecord::Migration
  def self.up
    change_table :cms_users do |t|
      t.string :authentication_token
    end

    add_index  :cms_users, :authentication_token, :unique => true
  end

  def self.down
    remove_column :cms_users, :authentication_token
  end
end
