class AddHeadFieldToLayouts < ActiveRecord::Migration

  def self.up
    text_limit = case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL'
        { }
      else
        { :limit => 16777215 }
      end
    add_column :cms_layouts, :head, :text, text_limit
  end

  def self.down
    remove_column :cms_layouts, :head
  end

end
