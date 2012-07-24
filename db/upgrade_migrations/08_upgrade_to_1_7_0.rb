class UpgradeTo170 < ActiveRecord::Migration
  def self.up
    # -- Sites --------------------------------------------------------------
    create_table :cms_site_aliases do |t|
      t.integer :site_id,     :null => false
      t.string :hostname,     :null => false
    end
    add_index :cms_site_aliases, :hostname
    add_index :cms_site_aliases, :site_id
  end

  def self.down
    drop_table :cms_site_aliases
  end
end
