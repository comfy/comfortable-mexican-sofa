class CreateFoos < ActiveRecord::Migration

  def change
    create_table :foos do |t|
      t.string :bar
      t.timestamps
    end
  end

end