class MoveBlocks < ActiveRecord::Migration
  def change
    rename_column :cms_blocks, :page_id, :page_content_id
  end
end
