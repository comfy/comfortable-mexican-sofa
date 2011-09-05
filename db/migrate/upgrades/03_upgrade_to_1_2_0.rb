class UpgradeTo120 < ActiveRecord::Migration
  def self.up
    ComfortableMexicanSofa.establish_connection(ActiveRecord::Base)
    create_table :cms_revisions, :force => true do |t|
      t.string    :record_type
      t.integer   :record_id
      t.text      :data
      t.datetime  :created_at
    end
    add_index :cms_revisions, [:record_type, :record_id, :created_at]
    ActiveRecord::Base.establish_connection
  end

  def self.down
    ComfortableMexicanSofa.establish_connection(ActiveRecord::Base)
    drop_table :cms_revisions
    ActiveRecord::Base.establish_connection
  end
end