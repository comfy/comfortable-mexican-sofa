class UpgradeTo120 < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.establish_connection "#{ComfortableMexicanSofa.config.database_config}#{Rails.env}"
    create_table :cms_revisions, :force => true do |t|
      t.string    :record_type
      t.integer   :record_id
      t.text      :data
      t.datetime  :created_at
    end
    add_index :cms_revisions, [:record_type, :record_id, :created_at]
  end

  def self.down
    ActiveRecord::Base.establish_connection "#{ComfortableMexicanSofa.config.database_config}#{Rails.env}"
    drop_table :cms_revisions
  end
end