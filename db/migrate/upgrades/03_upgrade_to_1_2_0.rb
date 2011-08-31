class UpgradeTo120 < ActiveRecord::Migration
  def self.up
    if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
      establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
    end
    create_table :cms_revisions, :force => true do |t|
      t.string    :record_type
      t.integer   :record_id
      t.text      :data
      t.datetime  :created_at
    end
    add_index :cms_revisions, [:record_type, :record_id, :created_at]
  end

  def self.down
    if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
      establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
    end
    drop_table :cms_revisions
  end
end